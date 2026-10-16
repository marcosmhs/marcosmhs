import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';

enum IntroTextDataStatus { created, saved, delete }

class IntroTextData {
  late String id;
  late String siteName;

  late DateTime? updateDate;

  late String introText;
  late double fontSize;
  late Color fontColor;
  late FontWeight fontWeight;

  late bool desktop;
  late bool mobile;
  late IntroTextDataStatus status;

  IntroTextData({
    this.id = '',
    required this.siteName,
    this.updateDate,
    Color? backgroundColor,
    this.introText = '',
    double? fontSize,
    FontWeight? fontWeight,
    this.status = IntroTextDataStatus.created,
  }) {
    this.fontWeight = fontWeight ?? Consts.stdIntroTextFontWeight;
    this.fontSize = fontSize ?? Consts.stdIntroTextFontSize;
  }

  static IntroTextData fromMap({required Map<String, dynamic> map}) {
    var u = IntroTextData(siteName: Consts.siteName);

    u = IntroTextData(
      id: map['id'] ?? '',
      siteName: map['siteName'] ?? '',
      updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
      introText: map['introText'] ?? '',
      fontSize: map['fontSize'] ?? Consts.stdIntroTextFontSize,
      fontWeight: map['fontWeight'] == null ? Consts.stdIntroTextFontWeight : FontWeight.values[map['fontWeight']],
      status: map['id'] == '' ? IntroTextDataStatus.created : IntroTextDataStatus.saved,
    );
    return u;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'id': id,
      'siteName': siteName,
      'updateDate': updateDate.toString(),
      'introText': introText,
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
    };

    return r;
  }
}
