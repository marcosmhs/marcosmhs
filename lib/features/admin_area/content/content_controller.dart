import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:marcosmhs/consts.dart';
import 'package:teb_package/util/teb_return.dart';

/// Tipos de item que têm página própria no site, com texto em Markdown.
enum ContentKind {
  article(
    collection: 'article',
    contentCollection: 'articleContent',
    idField: 'articleId',
    urlPrefix: '/artigos/',
    label: 'artigo',
    originLabel: 'Medium/LinkedIn',
  ),
  project(
    collection: 'project',
    contentCollection: 'projectContent',
    idField: 'projectId',
    urlPrefix: '/projetos/',
    label: 'projeto',
    originLabel: 'README do GitHub',
  );

  const ContentKind({
    required this.collection,
    required this.contentCollection,
    required this.idField,
    required this.urlPrefix,
    required this.label,
    required this.originLabel,
  });

  final String collection;
  final String contentCollection;
  final String idField;
  final String urlPrefix;
  final String label;
  final String originLabel;
}

/// Dados do item (artigo ou projeto) que o editor de texto usa.
class ContentItem {
  final ContentKind kind;
  final String id;
  final String title;
  final String originUrl;
  String slug;
  String summary;
  DateTime? date;

  ContentItem({
    required this.kind,
    required this.id,
    required this.title,
    required this.originUrl,
    this.slug = '',
    this.summary = '',
    this.date,
  });
}

/// Texto do item (Markdown) guardado em `articleContent/{id}` ou `projectContent/{id}`.
///
/// Fica separado do documento do item para que salvar a lista de artigos/projetos
/// nunca sobrescreva um texto editado aqui.
class ContentController {
  final ContentKind kind;
  ContentController(this.kind);

  final _db = FirebaseFirestore.instance;

  /// Ids dos itens que já têm texto no site.
  Future<Set<String>> idsWithContent() async {
    final snap = await _db.collection(kind.contentCollection).get();
    return snap.docs
        .where((d) => (d.data()['content'] ?? '').toString().trim().isNotEmpty)
        .map((d) => d.id)
        .toSet();
  }

  Future<String> load({required String id}) async {
    final doc = await _db.collection(kind.contentCollection).doc(id).get();
    return (doc.data()?['content'] ?? '').toString();
  }

  /// Relê slug, resumo e data do item (a importação pode tê-los preenchido).
  Future<void> refreshMeta(ContentItem item) async {
    final data = (await _db.collection(kind.collection).doc(item.id).get()).data() ?? {};
    item.slug = (data['slug'] ?? '').toString();
    item.summary = (data['summary'] ?? '').toString();
    if (kind == ContentKind.article) item.date = DateTime.tryParse((data['date'] ?? '').toString());
  }

  Future<TebReturn> save({required ContentItem item, required String content}) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      await _db.collection(kind.contentCollection).doc(item.id).set({
        kind.idField: item.id,
        'siteName': Consts.siteName,
        'content': content,
        'updatedAt': now,
      }, SetOptions(merge: true));
      await _db.collection(kind.collection).doc(item.id).update({
        'slug': item.slug,
        'summary': item.summary,
        if (kind == ContentKind.article) 'date': item.date?.toUtc().toIso8601String() ?? 'null',
        'updateDate': DateTime.now().toString(),
      });
      return TebReturn.success;
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  /// Envia uma imagem do editor para o Storage e devolve a URL pública.
  Future<String> uploadImage({required String id, required Uint8List bytes}) async {
    final isPng = bytes.length > 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
    final ext = isPng ? 'png' : 'jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('images/${kind.collection}s/$id/content/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: isPng ? 'image/png' : 'image/jpeg', cacheControl: 'public, max-age=31536000'),
    );
    return ref.getDownloadURL();
  }

  /// Importa o texto da origem (Medium/LinkedIn ou README do GitHub) pela Cloud Function `importContent`.
  Future<TebReturn> importFromOrigin({required String id, bool overwrite = false}) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1').httpsCallable(
        'importContent',
        options: HttpsCallableOptions(timeout: const Duration(minutes: 5)),
      );
      final result = await callable.call({'kind': kind.name, 'id': id, 'overwrite': overwrite});
      final data = Map<String, dynamic>.from(result.data as Map);
      final warnings = List<String>.from(data['warnings'] ?? const []);
      return TebReturn(
        returnType: TebReturnType.sucess,
        message: 'Importado: ${data['images'] ?? 0} imagens copiadas'
            '${warnings.isEmpty ? '' : '\nAvisos:\n${warnings.join('\n')}'}',
      );
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'already-exists') return TebReturn(returnType: TebReturnType.info, message: e.message ?? '');
      return TebReturn.error(e.message ?? e.code);
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }
}
