import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';

enum ArticleStatus { created, saved, delete }

class Article {
  late String id;
  late String siteName;
  late DateTime? updateDate;
  late ArticleStatus status;

  late int order;
  late String title;
  late String externalImageUrl;
  late String firestorageImageUrl;
  late String url;
  late String tag1;
  late String tag2;
  late DateTime? date;
  late MemoryImage? image;
  late bool removeFirestorageImage;

  Article({
    this.id = '',
    this.siteName = '',
    this.updateDate,
    this.status = ArticleStatus.created,
    this.order = 0,
    this.title = '',
    this.externalImageUrl = '',
    this.firestorageImageUrl = '',
    this.url = '',
    this.tag1 = '',
    this.tag2 = '',
    this.date,
    this.image,
    this.removeFirestorageImage = false,
  });

  void setToRemove() {
    status = ArticleStatus.delete;
  }

  static Article fromMap({required Map<String, dynamic> map}) {
    var u = Article(siteName: Consts.siteName);
    try {
      u = Article(
        id: map['id'] ?? '',
        siteName: map['siteName'] ?? '',
        updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
        order: map['order'] ?? 0,
        title: map['title'] ?? '',
        externalImageUrl: map['externalImageUrl'] ?? '',
        firestorageImageUrl: map['firestorageImageUrl'] ?? '',
        url: map['url'] ?? '',
        tag1: map['tag1'] ?? '',
        tag2: map['tag2'] ?? '',
        date: map['date'] == null ? null : DateTime.tryParse(map['date']),
      );
      return u;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return u;
    }
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'siteName': siteName,
      'updateDate': updateDate.toString(),
      'order': order,
      'title': title,
      'externalImageUrl': externalImageUrl,
      'firestorageImageUrl': firestorageImageUrl,
      'url': url,
      'tag1': tag1,
      'tag2': tag2,
      'date': date.toString(),
    };

    return r;
  }
}
