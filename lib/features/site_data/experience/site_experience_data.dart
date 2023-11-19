import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';

enum ExperienceStatus { created, saved, delete }

class Experience {
  late String id;
  late String siteName;
  late DateTime? updateDate;
  late ExperienceStatus status;

  late int order;
  late String title;
  late String company;
  late String description;
  late String durationStart;
  late String durationEnd;
  late IconData iconData;
  late Color iconBackgroundColor;
  late Color iconColor;

  Experience({
    this.order = 0,
    this.id = '',
    this.siteName = '',
    this.updateDate,
    this.status = ExperienceStatus.created,
    this.title = '',
    this.company = '',
    this.description = '',
    this.durationStart = '',
    this.durationEnd = '',
    IconData? iconData,
    Color? iconBackgroundColor,
    Color? iconColor,
  }) {
    this.iconBackgroundColor = iconBackgroundColor ?? Consts.stdExperienceBackgroundIconColor;
    this.iconColor = iconColor ?? Consts.stdExperienceIconColor;
    this.iconData = iconData ?? Consts.stdExperienceIconData;
  }

  void setToRemove() {
    status = ExperienceStatus.delete;
  }

  static Experience fromMap({required Map<String, dynamic> map}) {
    var u = Experience(siteName: Consts.siteName);
    try {
      u = Experience(
        id: map['id'] ?? '',
        siteName: map['siteName'] ?? '',
        updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
        status: map['id'] == '' ? ExperienceStatus.created : ExperienceStatus.saved,
        order: map['order'] ?? 0,
        title: map['title'],
        company: map['company'],
        description: map['description'],
        durationStart: map['durationStart'],
        durationEnd: map['durationEnd'],
        iconData: map['iconData'] == null ? Consts.stdExperienceIconData : IconDataSolid(map['iconData']),
        iconBackgroundColor:
            map['iconBackgroundColor'] == null ? Consts.stdExperienceBackgroundIconColor : Color(map['iconBackgroundColor']),
        iconColor: map['iconColor'] == null ? Consts.stdExperienceIconColor : Color(map['iconColor']),
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
      'company': company,
      'description': description,
      'durationStart': durationStart,
      'durationEnd': durationEnd,
      'iconData': iconData.codePoint,
      'iconBackgroundColor': iconBackgroundColor.value,
      'iconColor': iconColor.value,
    };

    return r;
  }
}
