import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';

class SiteMainData {
  late String siteName;

  late DateTime? updateDate;

  late Color backgroundColor;
  late Color secundaryBackgroundColor;
  late Color specialColor;
  late Color regularFontColor;
  late Color specialFontColor;

  late String aboutMeAreaTitle;
  late String experienceAreaTitle;
  late String articleAreaTitle;
  late String projectsAreaTitle;

  SiteMainData({
    required this.siteName,
    this.updateDate,
    Color? backgroundColor,
    Color? secundaryBackgroundColor,
    Color? specialColor,
    Color? regularFontColor,
    Color? specialFontColor,
    String? aboutMeAreaTitle,
    String? experienceAreaTitle,
    String? articleAreaTitle,
    String? projectsAreaTitle,
  }) {
    this.aboutMeAreaTitle = aboutMeAreaTitle ?? Consts.stdAboutMeAreaTitle;
    this.experienceAreaTitle = experienceAreaTitle ?? Consts.stdExperienceAreaTitle;
    this.articleAreaTitle = articleAreaTitle ?? Consts.stdArticleAreaTitle;
    this.projectsAreaTitle = projectsAreaTitle ?? Consts.stdProjectsAreaTitle;
  }

  SiteMainData fromMap2(Map<String, dynamic> map) {
    return SiteMainData.fromMap(map: map);
  }

  static SiteMainData fromMap({required Map<String, dynamic> map}) {
    var u = SiteMainData(siteName: Consts.siteName);

    u = SiteMainData(
      siteName: map['siteName'] ?? '',
      updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
      aboutMeAreaTitle: map['aboutMeAreaTitle'] ?? '',
      experienceAreaTitle: map['experienceAreaTitle'] ?? '',
      articleAreaTitle: map['articleAreaTitle'] ?? '',
      projectsAreaTitle: map['projectsAreaTitle'] ?? '',
    );
    return u;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'siteName': siteName,
      'updateDate': updateDate.toString(),
      'backgroundColor': backgroundColor.toARGB32(),
      'secundaryBackgroundColor': secundaryBackgroundColor.toARGB32(),
      'specialColor': specialColor.toARGB32(),
      'regularFontColor': regularFontColor.toARGB32(),
      'specialFontColor': specialFontColor.toARGB32(),
      'aboutMeAreaTitle': aboutMeAreaTitle,
      'experienceAreaTitle': experienceAreaTitle,
      'articleAreaTitle': articleAreaTitle,
      'projectsAreaTitle': projectsAreaTitle,
    };

    return r;
  }
}
