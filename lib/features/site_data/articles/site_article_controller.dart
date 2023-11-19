import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/site_data/articles/site_article_data.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class ArticlesController with ChangeNotifier {
  Future<List<Article>> getData({required String siteName}) async {
    if (siteName.isEmpty) return [];

    final dataRef = await FirebaseFirestore.instance.collection(FirebaseConsts.articleCollectionName).get();

    final dataList = dataRef.docs.map((doc) => doc.data()).toList();

    final List<Article> r = [];
    for (var article in dataList) {
      r.add(Article.fromMap(map: article));
    }
    r.sort((a, b) => b.order.compareTo(a.order));
    return r;
  }

  Future<String> _saveImageOnStorage({
    required MemoryImage image,
    required String imageName,
  }) async {
    try {
      var ref = FirebaseStorage.instance.ref().child('images/articles/$imageName.jpeg');
      await ref.putData(
        image.bytes,
        SettableMetadata(contentType: "image/jpeg"),
      );
      String url = (await ref.getDownloadURL()).toString();
      return url;
    } catch (e) {
      return '';
    }
  }

  Future<TebCustomReturn> save({required List<Article> articleList}) async {
    try {
      for (var article in articleList) {
        if (article.status == ArticleStatus.delete) {
          await FirebaseFirestore.instance.collection(FirebaseConsts.articleCollectionName).doc(article.id).delete();
        } else {
          article.updateDate = DateTime.now();

          if (article.id.isEmpty) article.id = TebUidGenerator.firestoreUid;

          if (article.image != null) {
            article.firestorageImageUrl = await _saveImageOnStorage(
              image: article.image!,
              imageName: article.id,
            );
            if (article.firestorageImageUrl.isEmpty) {
              return TebCustomReturn.error('Erro ao salvar a foto');
            } else {
              article.externalImageUrl = '';
            }
          }

          if (article.removeFirestorageImage) {
            await FirebaseStorage.instance.refFromURL(article.firestorageImageUrl).delete();
            article.firestorageImageUrl = '';
          }
          await FirebaseFirestore.instance.collection(FirebaseConsts.articleCollectionName).doc(article.id).set(article.toMap);
        }
      }

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
