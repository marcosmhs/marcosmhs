// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/site_publisher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/main_area_structure.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:marcosmhs/features/admin_area/articles/article_controller.dart';
import 'package:marcosmhs/features/admin_area/content/content_controller.dart';
import 'package:marcosmhs/features/admin_area/articles/article_data.dart';
import 'package:teb_package/teb_package.dart';

class ArticleForm extends StatefulWidget {
  const ArticleForm({super.key});

  @override
  State<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends State<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  var _initializing = true;
  var _saveingData = false;
  final List<Article> _articleList = [];
  Set<String> _idsWithContent = {};
  var _importing = false;
  var _importStatus = '';

  Future<void> _loadContentStatus() async {
    final ids = await ContentController(ContentKind.article).idsWithContent();
    if (mounted) setState(() => _idsWithContent = ids);
  }

  Future<void> _openContentEditor(Article article) async {
    await Navigator.of(context).pushNamed(
      Routes.contentForm,
      arguments: {
        'user': _user,
        'item': ContentItem(
          kind: ContentKind.article,
          id: article.id,
          title: article.title,
          originUrl: article.url,
          slug: article.slug,
          summary: article.summary,
          date: article.date,
        ),
      },
    );
    // o editor/importação podem ter preenchido slug, resumo, data e capa
    final articles = await ArticlesController().getData(siteName: Consts.siteName);
    if (!mounted) return;
    setState(() {
      _articleList
        ..clear()
        ..addAll(articles);
    });
    _loadContentStatus();
  }

  /// Importa o texto de todos os artigos salvos que ainda não têm texto no site.
  Future<void> _importAll() async {
    final pending = _articleList
        .where((a) => a.id.isNotEmpty && !_idsWithContent.contains(a.id) && a.url.isNotEmpty)
        .toList();
    if (pending.isEmpty) {
      TebMessage.info(context, message: 'Todos os artigos já têm texto no site.');
      return;
    }
    setState(() => _importing = true);
    final controller = ContentController(ContentKind.article);
    final errors = <String>[];
    for (var i = 0; i < pending.length; i++) {
      setState(() => _importStatus = 'Importando ${i + 1} de ${pending.length}: ${pending[i].title}');
      final r = await controller.importFromOrigin(id: pending[i].id);
      if (!r.isSuccess) errors.add('${pending[i].title}: ${r.message}');
    }
    if (!mounted) return;
    setState(() {
      _importing = false;
      _importStatus = '';
    });
    if (errors.isEmpty) {
      TebMessage.success(context, message: '${pending.length} artigos importados. O site será atualizado.');
    } else {
      TebMessage.error(context, message: 'Falharam ${errors.length}:\n${errors.join('\n')}');
    }
    SitePublisher.instance.requestPublish();
    final articles = await ArticlesController().getData(siteName: Consts.siteName);
    if (!mounted) return;
    setState(() {
      _articleList
        ..clear()
        ..addAll(articles);
    });
    _loadContentStatus();
  }

  void _addArticleList() {
    List<Article> articleListBkp = [];
    articleListBkp.addAll(_articleList);

    articleListBkp.add(Article(siteName: Consts.siteName));
    _articleList.clear();
    _articleList.addAll(articleListBkp);
    setState(() {});
  }

  void _setArticleToRemove({required Article article}) {
    TebDialog(context: context).confirmationDialog(message: 'Excluir este artigo?').then((value) {
      if (value == true) {
        if (article.id.isEmpty) {
          setState(() => _articleList.remove(article));
        } else {
          setState(() => article.setToRemove());
        }
      }
    });
  }

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var articlesController = ArticlesController();
      TebReturn retorno;
      try {
        retorno = await articlesController.save(articleList: _articleList);

        if (retorno.returnType == TebReturnType.sucess) {
          TebMessage.success(context, message: 'Dados alterados com sucesso');
          SitePublisher.instance.requestPublish();
          Navigator.of(context).pushReplacementNamed(Routes.mainScreen, arguments: {'user': _user});
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebMessage.error(context, message: retorno.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  String? _textEditValidator(String? value, String errorMessage) {
    var finalValue = value ?? '';
    if (finalValue.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  Widget _imageArea({required Article article}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.11,
      child: Column(
        children: [
          // se carregou imagem
          if (article.image != null) Image(image: article.image!, fit: BoxFit.contain),
          if (article.image == null)
            (article.externalImageUrl.isEmpty && article.firestorageImageUrl.isEmpty) ||
                    (article.firestorageImageUrl.isNotEmpty && article.removeFirestorageImage)
                ? Image.asset('assets/images/no_image.gif')
                : Image.network(
                    article.externalImageUrl.isNotEmpty
                        ? article.externalImageUrl
                        : article.firestorageImageUrl,
                    fit: BoxFit.contain,
                  ),
          const SizedBox(height: 10),
          TebFilePickerWeb(
            buttonLabel: 'Imagem',
            icon: Icon(FontAwesomeIcons.image, color: Theme.of(context).colorScheme.surface),
            onPicked: (image) {
              article.removeFirestorageImage = false;
              setState(() => article.image = image);
            },
          ),
          TebButton(
            icon: Icon(FontAwesomeIcons.trashCan, color: Theme.of(context).colorScheme.surface),
            label: 'Remover Imagem',
            onPressed: () {
              if (article.firestorageImageUrl.isNotEmpty) {
                setState(() => article.removeFirestorageImage = true);
              }

              if (article.image != null) {
                setState(() => article.image = null);
              }
            },
            padding: const EdgeInsets.only(top: 10),
          ),
        ],
      ),
    );
  }

  Widget _articleItem({required Article article}) {
    final size = MediaQuery.of(context).size;

    final TextEditingController orderController =
        TextEditingController(text: article.order.toString());
    final TextEditingController titleController = TextEditingController(text: article.title);
    final TextEditingController externalImageUrlController =
        TextEditingController(text: article.externalImageUrl);
    final TextEditingController urlController = TextEditingController(text: article.url);
    final TextEditingController tag1Controller = TextEditingController(text: article.tag1);
    final TextEditingController tag2Controller = TextEditingController(text: article.tag2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // image
          _imageArea(article: article),
          // text info
          SizedBox(
            width: size.width * 0.52,
            child: Column(
              children: [
                Row(
                  children: [
                    TebTextEdit(
                      width: size.width * 0.05,
                      labelText: 'Ordem',
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      onSave: (value) => article.order = int.tryParse(value ?? '') ?? 0,
                      onChanged: (value) => article.order = int.tryParse(value ?? '') ?? 0,
                      validator: (value) => _textEditValidator(value, 'Informe a ordem'),
                    ),
                    const Spacer(),
                    TebTextEdit(
                      width: size.width * 0.46,
                      labelText: 'Titulo',
                      controller: titleController,
                      onSave: (value) => article.title = value ?? '',
                      onChanged: (value) => article.title = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o título'),
                    ),
                  ],
                ),
                TebTextEdit(
                  labelText: 'URL do artigo',
                  controller: urlController,
                  onSave: (value) => article.url = value ?? '',
                  onChanged: (value) => article.url = value ?? '',
                  validator: (value) => _textEditValidator(value, 'Informe a url do artigo'),
                ),
                TebTextEdit(
                  enabled: article.image == null,
                  labelText:
                      article.image == null ? 'URL da Imagem' : 'Utilizando a imagem carregada',
                  controller: externalImageUrlController,
                  onSave: (value) => article.externalImageUrl = value ?? '',
                  onChanged: (value) => setState(() => article.externalImageUrl = value ?? ''),
                  validator: (value) =>
                      article.image != null || article.firestorageImageUrl.isNotEmpty
                          ? null
                          : _textEditValidator(value, 'Informe a url da imagem'),
                ),
                Row(
                  children: [
                    TebTextEdit(
                      width: 150,
                      labelText: 'TAG 1 ',
                      controller: tag1Controller,
                      onSave: (value) => article.tag1 = value ?? '',
                      onChanged: (value) => article.tag1 = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o TAG 1'),
                      padding: const EdgeInsets.only(right: 5),
                    ),
                    TebTextEdit(
                      width: 150,
                      labelText: 'TAG 2',
                      controller: tag2Controller,
                      onSave: (value) => article.tag2 = value ?? '',
                      onChanged: (value) => article.tag2 = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o TAG 2'),
                      padding: const EdgeInsets.only(left: 5),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        value: article.category,
                        decoration: const InputDecoration(labelText: 'Categoria no site'),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('Automática (pela URL)')),
                          DropdownMenuItem(value: 'lead', child: Text('Liderança & estratégia')),
                          DropdownMenuItem(value: 'tech', child: Text('Tutorial técnico')),
                        ],
                        onChanged: (value) => article.category = value ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // remove option
          SizedBox(
            width: size.width * 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TebButton(
                  label: 'Remover',
                  icon: FaIcon(FontAwesomeIcons.trashCan,
                      color: Theme.of(context).colorScheme.surface),
                  onPressed: () => _setArticleToRemove(article: article),
                  enabled: article.status != ArticleStatus.delete,
                ),
                if (article.status == ArticleStatus.delete)
                  const TebText(
                    'Excluído',
                    padding: EdgeInsets.all(8),
                  ),
                const SizedBox(height: 8),
                TebButton(
                  label: 'Texto no site',
                  buttonType: TebButtonType.outlinedButton,
                  icon: FaIcon(
                    _idsWithContent.contains(article.id) ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.penToSquare,
                    size: 16,
                  ),
                  enabled: article.id.isNotEmpty && article.status != ArticleStatus.delete && !_importing,
                  onPressed: () => _openContentEditor(article),
                ),
                if (article.id.isEmpty)
                  const TebText('Salve antes de escrever o texto', fontSize: 11, padding: EdgeInsets.all(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      ArticlesController().getData(siteName: Consts.siteName).then((articleList) {
        _articleList.clear();
        if (articleList.isEmpty) articleList.add(Article(siteName: Consts.siteName));
        setState(() => _articleList.addAll(articleList));
      });
      _loadContentStatus();
      _initializing = false;
    }

    final Size size = MediaQuery.of(context).size;

    return MainAreaStructure(
      mobile: size.width < 1000,
      user: _user,
      size: size,
      widget: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // button options
            TebButtonsLine(
              mainAxisAlignment: MainAxisAlignment.end,
              padding: const EdgeInsets.symmetric(vertical: 10),
              buttons: [
                const Spacer(),
                TebButton(
                  label: 'Cancelar',
                  icon: const FaIcon(FontAwesomeIcons.ban),
                  buttonType: TebButtonType.outlinedButton,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TebButton(
                  label: 'Salvar',
                  icon: FaIcon(FontAwesomeIcons.floppyDisk,
                      color: Theme.of(context).colorScheme.surface),
                  onPressed: () => _submit(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // intro text title
            Row(
              children: [
                const TebText('Artigos escritos', fontSize: 20),
                const Spacer(),
                if (_importing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TebText(_importStatus, fontSize: 12),
                  ),
                TebButton(
                  label: 'Importar textos do Medium/LinkedIn',
                  buttonType: TebButtonType.outlinedButton,
                  icon: const FaIcon(FontAwesomeIcons.fileImport, size: 16),
                  enabled: !_importing,
                  onPressed: _importAll,
                ),
                const SizedBox(width: 10),
                TebButton(
                  label: 'Adicionar novo artigo',
                  icon: FaIcon(FontAwesomeIcons.plus, color: Theme.of(context).colorScheme.surface),
                  onPressed: () => _addArticleList(),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.8,
              width: size.width * 0.78,
              child: ListView.builder(
                itemCount: _articleList.length,
                itemBuilder: (itemBuildercontext, index) {
                  return _articleItem(article: _articleList[index]);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
