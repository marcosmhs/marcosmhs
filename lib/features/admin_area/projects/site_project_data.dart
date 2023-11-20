import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';

enum ProjectStatus { created, saved, delete }

class Project {
  late String id;
  late String siteName;
  late DateTime? updateDate;
  late ProjectStatus status;

  late int order;
  late String title;
  late String description;
  late String externalImageUrl;
  late String firestorageImageUrl;
  late String url;
  late String urlGithub;
  late String tag1;
  late String tag2;
  late String tag3;
  late MemoryImage? image;
  late bool removeFirestorageImage;

  Project({
    this.id = '',
    this.siteName = '',
    this.updateDate,
    this.status = ProjectStatus.created,
    this.order = 0,
    this.title = '',
    this.description = '',
    this.externalImageUrl = '',
    this.firestorageImageUrl = '',
    this.url = '',
    this.urlGithub = '',
    this.tag1 = '',
    this.tag2 = '',
    this.tag3 = '',
    this.image,
    this.removeFirestorageImage = false,
  });

  void setToRemove() {
    status = ProjectStatus.delete;
  }

  static Project fromMap({required Map<String, dynamic> map}) {
    var u = Project(siteName: Consts.siteName);
    try {
      u = Project(
        id: map['id'] ?? '',
        siteName: map['siteName'] ?? '',
        updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
        order: map['order'] ?? 0,
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        externalImageUrl: map['externalImageUrl'] ?? '',
        firestorageImageUrl: map['firestorageImageUrl'] ?? '',
        url: map['url'] ?? '',
        urlGithub: map['urlGithub'] ?? '',
        tag1: map['tag1'] ?? '',
        tag2: map['tag2'] ?? '',
        tag3: map['tag3'] ?? '',
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
      'description': description,
      'externalImageUrl': externalImageUrl,
      'firestorageImageUrl': firestorageImageUrl,
      'url': url,
      'urlGithub': urlGithub,
      'tag1': tag1,
      'tag2': tag2,
      'tag3': tag3,
    };

    return r;
  }
}
