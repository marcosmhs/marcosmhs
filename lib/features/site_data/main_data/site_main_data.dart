import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';

class SiteMainData {
  late String siteName;

  late DateTime? updateDate;

  late Color backgroundColor;
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
    Color? specialColor,
    Color? regularFontColor,
    Color? specialFontColor,
    String? aboutMeAreaTitle,
    String? experienceAreaTitle,
    String? articleAreaTitle,
    String? projectsAreaTitle,
  }) {
    this.backgroundColor = backgroundColor ?? Consts.stdBackgroundColor;
    this.specialColor = specialColor ?? Consts.stdSpecialColor;
    this.regularFontColor = regularFontColor ?? Consts.stdRegularFontColor;
    this.specialFontColor = specialFontColor ?? Consts.stdSpecialFontColor;

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
      backgroundColor: map['backgroundColor'] == null ? Consts.stdBackgroundColor : Color(map['backgroundColor']),
      specialColor: map['specialColor'] == null ? Consts.stdSpecialColor : Color(map['specialColor']),
      regularFontColor: map['regularFontColor'] == null ? Consts.stdRegularFontColor : Color(map['regularFontColor']),
      specialFontColor: map['specialFontColor'] == null ? Consts.stdSpecialFontColor : Color(map['specialFontColor']),
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
      'backgroundColor': backgroundColor.value,
      'specialColor': specialColor.value,
      'regularFontColor': regularFontColor.value,
      'specialFontColor': specialFontColor.value,
      'aboutMeAreaTitle': aboutMeAreaTitle,
      'experienceAreaTitle': experienceAreaTitle,
      'articleAreaTitle': articleAreaTitle,
      'projectsAreaTitle': projectsAreaTitle,
    };

    return r;
  }
}
