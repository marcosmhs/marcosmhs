import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/admin_area/content/content_controller.dart';
import 'package:marcosmhs/features/admin_area/main_area_structure.dart';
import 'package:marcosmhs/features/admin_area/site_publisher.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:teb_package/teb_package.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Editor do texto de artigos e projetos (Markdown) com barra de formatação e pré-visualização.
///
/// Recursos: títulos, negrito, itálico, links, listas, citações, código (bloco e inline),
/// imagens com legenda e separador — os mesmos usados nos artigos do Medium e do LinkedIn.
class ContentForm extends StatefulWidget {
  const ContentForm({super.key});

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  late ContentController _controller;
  final _text = TextEditingController();
  final _slug = TextEditingController();
  final _summary = TextEditingController();
  final _focus = FocusNode();

  var _user = User();
  late ContentItem _item;
  var _initializing = true;
  var _loading = true;
  var _busy = false;
  var _dirty = false;
  var _showPreviewOnMobile = false;

  @override
  void dispose() {
    _text.dispose();
    _slug.dispose();
    _summary.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final content = await _controller.load(id: _item.id);
    if (!mounted) return;
    setState(() {
      _text.text = content;
      _slug.text = _item.slug;
      _summary.text = _item.summary;
      _loading = false;
      _dirty = false;
    });
  }

  // ---------- edição ----------

  /// Envolve a seleção com [before]/[after]; sem seleção, insere [placeholder] já selecionado.
  void _wrap(String before, String after, {String placeholder = 'texto'}) {
    final value = _text.value;
    final sel = value.selection.isValid ? value.selection : TextSelection.collapsed(offset: value.text.length);
    final selected = sel.textInside(value.text);
    final inner = selected.isEmpty ? placeholder : selected;
    final newText = value.text.replaceRange(sel.start, sel.end, '$before$inner$after');
    _text.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: sel.start + before.length,
        extentOffset: sel.start + before.length + inner.length,
      ),
    );
    _changed();
  }

  /// Aplica [prefix] no início de cada linha selecionada (títulos, listas, citação).
  void _prefixLines(String Function(int index) prefix, {RegExp? replaceExisting}) {
    final value = _text.value;
    final sel = value.selection.isValid ? value.selection : TextSelection.collapsed(offset: value.text.length);
    final start = value.text.lastIndexOf('\n', sel.start == 0 ? 0 : sel.start - 1) + 1;
    var end = value.text.indexOf('\n', sel.end);
    if (end < 0) end = value.text.length;
    final lines = value.text.substring(start, end).split('\n');
    final changed = <String>[];
    for (var i = 0; i < lines.length; i++) {
      final line = replaceExisting == null ? lines[i] : lines[i].replaceFirst(replaceExisting, '');
      changed.add('${prefix(i)}$line');
    }
    final block = changed.join('\n');
    _text.value = TextEditingValue(
      text: value.text.replaceRange(start, end, block),
      selection: TextSelection.collapsed(offset: start + block.length),
    );
    _changed();
  }

  void _insertBlock(String block, {int? cursorFromStart}) {
    final value = _text.value;
    final pos = value.selection.isValid ? value.selection.end : value.text.length;
    final before = value.text.substring(0, pos);
    final lead = before.isEmpty || before.endsWith('\n\n') ? '' : (before.endsWith('\n') ? '\n' : '\n\n');
    final insert = '$lead$block\n\n';
    _text.value = TextEditingValue(
      text: value.text.replaceRange(pos, value.selection.isValid ? value.selection.end : pos, insert),
      selection: TextSelection.collapsed(offset: pos + lead.length + (cursorFromStart ?? block.length)),
    );
    _changed();
  }

  void _codeBlock() {
    final value = _text.value;
    final selected = value.selection.isValid ? value.selection.textInside(value.text) : '';
    if (selected.contains('\n') || selected.isEmpty) {
      _wrap('```\n', '\n```', placeholder: 'código');
    } else {
      _wrap('`', '`', placeholder: 'código');
    }
  }

  void _link() {
    final value = _text.value;
    final selected = value.selection.isValid ? value.selection.textInside(value.text) : '';
    final isUrl = selected.startsWith('http');
    _wrap(isUrl ? '[texto do link](' : '[', isUrl ? ')' : '](https://)', placeholder: 'texto do link');
  }

  Future<void> _uploadImage(MemoryImage image) async {
    final caption = await _askCaption();
    if (caption == null) return;
    setState(() => _busy = true);
    try {
      final url = await _controller.uploadImage(id: _item.id, bytes: image.bytes);
      final safe = caption.replaceAll('"', "'").replaceAll(']', ')').replaceAll('[', '(');
      _insertBlock(safe.isEmpty ? '![]($url)' : '![$safe]($url "$safe")');
    } catch (e) {
      if (mounted) TebMessage.error(context, message: 'Erro ao enviar a imagem: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askCaption() {
    final caption = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Legenda da imagem'),
        content: TextField(
          controller: caption,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Opcional — também usada como texto alternativo'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(caption.text.trim()), child: const Text('Inserir')),
        ],
      ),
    );
  }

  void _changed() {
    if (!_dirty) setState(() => _dirty = true);
    setState(() {});
  }

  // ---------- ações ----------

  Future<void> _save() async {
    setState(() => _busy = true);
    _item.slug = _slug.text.trim();
    _item.summary = _summary.text.trim();
    final r = await _controller.save(item: _item, content: _text.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.isSuccess) {
      setState(() => _dirty = false);
      TebMessage.success(context, message: 'Texto salvo. O site será atualizado em instantes.');
      SitePublisher.instance.requestPublish();
    } else {
      TebMessage.error(context, message: r.message);
    }
  }

  Future<void> _import() async {
    final hasText = _text.text.trim().isNotEmpty;
    if (hasText) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Substituir o texto?'),
          content: Text('O texto atual será trocado pelo que está publicado em:\n${_item.originUrl}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Substituir')),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _busy = true);
    final r = await _controller.importFromOrigin(id: _item.id, overwrite: hasText);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.isSuccess) {
      // a função também preenche slug, resumo, data e capa no documento do item
      final updated = await _controller.load(id: _item.id);
      await _controller.refreshMeta(_item);
      if (!mounted) return;
      setState(() {
        _text.text = updated;
        _slug.text = _item.slug;
        _summary.text = _item.summary;
        _dirty = false;
      });
      TebMessage.success(context, message: r.message);
      SitePublisher.instance.requestPublish();
    } else {
      TebMessage.error(context, message: r.message);
    }
  }

  // ---------- interface ----------

  Widget _toolButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: FaIcon(icon, size: 16),
      tooltip: tooltip,
      onPressed: _busy ? null : onPressed,
    );
  }

  Widget _toolbar() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _toolButton(FontAwesomeIcons.heading, 'Título de seção (##)',
            () => _prefixLines((_) => '## ', replaceExisting: RegExp(r'^#{1,6}\s+'))),
        TextButton(
          onPressed: _busy ? null : () => _prefixLines((_) => '### ', replaceExisting: RegExp(r'^#{1,6}\s+')),
          child: const Text('H3'),
        ),
        _toolButton(FontAwesomeIcons.bold, 'Negrito (Ctrl+B)', () => _wrap('**', '**')),
        _toolButton(FontAwesomeIcons.italic, 'Itálico (Ctrl+I)', () => _wrap('*', '*')),
        _toolButton(FontAwesomeIcons.link, 'Link (Ctrl+K)', _link),
        _toolButton(FontAwesomeIcons.listUl, 'Lista', () => _prefixLines((_) => '- ')),
        _toolButton(FontAwesomeIcons.listOl, 'Lista numerada', () => _prefixLines((i) => '${i + 1}. ')),
        _toolButton(FontAwesomeIcons.quoteLeft, 'Citação', () => _prefixLines((_) => '> ')),
        _toolButton(FontAwesomeIcons.code, 'Código (seleção de várias linhas vira bloco)', _codeBlock),
        _toolButton(FontAwesomeIcons.minus, 'Separador', () => _insertBlock('---')),
        TebFilePickerWeb(
          buttonLabel: 'Imagem',
          icon: Icon(FontAwesomeIcons.image, size: 16, color: Theme.of(context).colorScheme.surface),
          onPicked: _uploadImage,
        ),
      ],
    );
  }

  Widget _editor(double height) {
    return SizedBox(
      height: height,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyB, control: true): () => _wrap('**', '**'),
          const SingleActivator(LogicalKeyboardKey.keyI, control: true): () => _wrap('*', '*'),
          const SingleActivator(LogicalKeyboardKey.keyK, control: true): _link,
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
        },
        child: TextField(
          controller: _text,
          focusNode: _focus,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.5),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Escreva o artigo aqui. Use a barra acima para formatar.',
          ),
          onChanged: (_) => _changed(),
        ),
      ),
    );
  }

  Widget _preview(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Markdown(
        data: _text.text,
        selectable: true,
        padding: const EdgeInsets.all(20),
        onTapLink: (text, href, title) {
          if (href != null) launchUrlString(href);
        },
        imageBuilder: (uri, title, alt) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Image.network(
                uri.toString(),
                errorBuilder: (_, _, _) => Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF3F3F6),
                  child: Text('Imagem: ${alt ?? uri}', textAlign: TextAlign.center),
                ),
              ),
              if ((title ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(title!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ),
            ],
          ),
        ),
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          code: const TextStyle(fontFamily: 'monospace', fontSize: 13, backgroundColor: Color(0xFFF3F3F6)),
          codeblockDecoration: BoxDecoration(color: const Color(0xFFF3F3F6), borderRadius: BorderRadius.circular(6)),
          blockquoteDecoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFF5B5BD6), width: 3)),
          ),
        ),
      ),
    );
  }

  Widget _meta(bool mobile) {
    final slugField = TextField(
      controller: _slug,
      decoration: InputDecoration(
        labelText: 'Endereço (slug)',
        helperText: '${_item.kind.urlPrefix}${_slug.text.isEmpty ? '<gerado-do-título>' : _slug.text}/',
      ),
      onChanged: (_) => _changed(),
    );
    final summaryField = TextField(
      controller: _summary,
      maxLength: 200,
      decoration: const InputDecoration(
        labelText: 'Resumo',
        helperText: 'Aparece abaixo do título e no resultado do Google (ideal: até 160 caracteres)',
      ),
      onChanged: (_) => _changed(),
    );
    final d = _item.date;
    final dateField = _item.kind == ContentKind.article
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.calendar, size: 14),
              label: Text(d == null
                  ? 'Data de publicação'
                  : 'Publicado em ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}'),
              onPressed: _busy ? null : _pickDate,
            ),
          )
        : null;
    if (mobile) return Column(children: [slugField, summaryField, ?dateField]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: slugField),
        const SizedBox(width: 16),
        Expanded(flex: 5, child: summaryField),
        if (dateField != null) ...[const SizedBox(width: 16), dateField],
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _item.date?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Data de publicação do artigo',
    );
    if (picked != null) {
      setState(() => _item.date = DateTime.utc(picked.year, picked.month, picked.day, 12));
      _changed();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      _item = arguments['item'] as ContentItem;
      _controller = ContentController(_item.kind);
      _initializing = false;
      _load();
    }

    final size = MediaQuery.of(context).size;
    final mobile = size.width < 1000;
    final editorHeight = size.height * 0.62;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sair sem salvar?'),
            content: const Text('As alterações no texto serão perdidas.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Continuar editando')),
              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sair')),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          setState(() => _dirty = false);
          Navigator.of(context).pop();
        }
      },
      child: MainAreaStructure(
        mobile: mobile,
        user: _user,
        size: size,
        widget: _loading
            ? const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TebButtonsLine(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    buttons: [
                      Expanded(
                        child: TebText(
                          'Texto do ${_item.kind.label}: ${_item.title}${_dirty ? '  •  não salvo' : ''}',
                          fontSize: 18,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_busy) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
                      TebButton(
                        label: 'Importar do ${_item.kind.originLabel}',
                        icon: const FaIcon(FontAwesomeIcons.fileImport),
                        buttonType: TebButtonType.outlinedButton,
                        enabled: !_busy && _item.originUrl.isNotEmpty,
                        onPressed: _import,
                      ),
                      TebButton(
                        label: 'Voltar',
                        icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                        buttonType: TebButtonType.outlinedButton,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      TebButton(
                        label: 'Salvar',
                        icon: FaIcon(FontAwesomeIcons.floppyDisk, color: Theme.of(context).colorScheme.surface),
                        enabled: !_busy,
                        onPressed: _save,
                      ),
                    ],
                  ),
                  _meta(mobile),
                  const SizedBox(height: 8),
                  _toolbar(),
                  if (mobile)
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Editar')),
                        ButtonSegment(value: true, label: Text('Pré-visualizar')),
                      ],
                      selected: {_showPreviewOnMobile},
                      onSelectionChanged: (s) => setState(() => _showPreviewOnMobile = s.first),
                    ),
                  const SizedBox(height: 8),
                  if (mobile)
                    _showPreviewOnMobile ? _preview(editorHeight) : _editor(editorHeight)
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _editor(editorHeight)),
                        const SizedBox(width: 16),
                        Expanded(child: _preview(editorHeight)),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}
