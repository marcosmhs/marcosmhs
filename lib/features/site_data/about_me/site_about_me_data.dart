import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';

class AboutMeData {
  late String siteName;
  late String profilePhotoUrl;
  late DateTime? updateDate;
  late MemoryImage? photo;

  AboutMeData({
    required this.siteName,
    this.updateDate,
    this.profilePhotoUrl = '',
    this.photo,
  });

  static AboutMeData fromMap({required Map<String, dynamic> map}) {
    var u = AboutMeData(siteName: Consts.siteName);

    u = AboutMeData(
      siteName: map['siteName'] ?? '',
      updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
      profilePhotoUrl: map['profilePhotoUrl'] ?? '',
    );
    return u;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'siteName': siteName,
      'updateDate': updateDate.toString(),
      'profilePhotoUrl': profilePhotoUrl,
    };

    return r;
  }
}

enum AboutMeItemStatus { created, saved, delete }

enum AboutMeTechnologyType { development, dataScience }

class AboutMeTechnology {
  late String id;
  late AboutMeTechnologyType type;
  late String siteName;
  late DateTime? updateDate;
  late AboutMeItemStatus status;

  late String technologyName;
  late bool desktop;
  late bool mobile;

  AboutMeTechnology({
    this.id = '',
    this.siteName = '',
    this.updateDate,
    this.type = AboutMeTechnologyType.development,
    this.technologyName = '',
    this.desktop = true,
    this.mobile = true,
    this.status = AboutMeItemStatus.created,
  });

  static AboutMeTechnology fromMap({required Map<String, dynamic> map}) {
    var u = AboutMeTechnology(siteName: Consts.siteName);

    u = AboutMeTechnology(
      id: map['id'] ?? '',
      siteName: map['siteName'] ?? '',
      updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
      type: aboutMeTechnologyTypeFromString(map['type']),
      technologyName: map['technologyName'] ?? '',
      mobile: map['mobile'],
      desktop: map['desktop'],
      status: map['id'] == '' ? AboutMeItemStatus.created : AboutMeItemStatus.saved,
    );
    return u;
  }

  static AboutMeTechnologyType aboutMeTechnologyTypeFromString(String value) {
    return value == 'AboutMeTechnologyType.development' ? AboutMeTechnologyType.development : AboutMeTechnologyType.dataScience;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'siteName': siteName,
      'updateDate': updateDate.toString(),
      'type': type.toString(),
      'technologyName': technologyName,
      'desktop': desktop,
      'mobile': mobile,
    };

    return r;
  }
}

class AboutMeText {
  late String id;
  late String siteName;

  late DateTime? updateDate;

  late String aboutMeText;
  late double fontSize;
  late Color fontColor;
  late FontWeight fontWeight;

  late bool desktop;
  late bool mobile;
  late AboutMeItemStatus status;

  AboutMeText({
    this.id = '',
    required this.siteName,
    this.updateDate,
    Color? backgroundColor,
    this.aboutMeText = '',
    double? fontSize,
    Color? fontColor,
    FontWeight? fontWeight,
    this.desktop = true,
    this.mobile = true,
    this.status = AboutMeItemStatus.created,
  }) {
    this.fontColor = fontColor ?? Consts.stdIntroTextFontColor;
    this.fontWeight = fontWeight ?? Consts.stdIntroTextFontWeight;
    this.fontSize = fontSize ?? Consts.stdIntroTextFontSize;
  }

  static AboutMeText fromMap({required Map<String, dynamic> map}) {
    var u = AboutMeText(siteName: Consts.siteName);

    u = AboutMeText(
      id: map['id'] ?? '',
      siteName: map['siteName'] ?? '',
      updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
      aboutMeText: map['aboutMeText'] ?? '',
      fontSize: map['fontSize'] ?? Consts.stdIntroTextFontSize,
      fontColor: map['fontColor'] == null ? Consts.stdIntroTextFontColor : Color(map['fontColor']),
      fontWeight: map['fontWeight'] == null ? Consts.stdIntroTextFontWeight : FontWeight.values[map['fontWeight']],
      desktop: map['desktop'],
      mobile: map['mobile'],
      status: map['id'] == '' ? AboutMeItemStatus.created : AboutMeItemStatus.saved,
    );
    return u;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'siteName': siteName,
      'updateDate': updateDate.toString(),
      'aboutMeText': aboutMeText,
      'fontSize': fontSize,
      'fontColor': fontColor.value,
      'fontWeight': fontWeight.index,
      'desktop': desktop,
      'mobile': mobile,
    };

    return r;
  }
}
