import 'package:flutter/material.dart';
import 'package:marcosmhs/consts.dart';

class SiteHeaderText {
  late String siteName;

  late DateTime? updateDate;
  late String name;
  late double nameFontSize;
  late Color nameColor;
  late FontWeight nameFontWeight;

  late String nameComplement;
  late double nameComplementFontSize;
  late Color nameComplementColor;
  late FontWeight nameComplementFontWeight;

  late String email;
  late String urlGitGub;
  late String urlLinkedin;
  late String urlMedium;

  SiteHeaderText({
    required this.siteName,
    this.updateDate,
    this.name = '',
    double? nameFontSize,
    Color? nameColor,
    FontWeight? nameFontWeight,
    this.nameComplement = '',
    double? nameComplementFontSize,
    Color? nameComplementColor,
    FontWeight? nameComplementFontWeight,
    this.email = '',
    this.urlGitGub = '',
    this.urlLinkedin = '',
    this.urlMedium = '',
  }) {
    this.nameColor = nameColor ?? Consts.stdNameFontColor;
    this.nameFontWeight = nameFontWeight ?? Consts.stdNameFontWeight;
    this.nameFontSize = nameFontSize ?? Consts.stdNameFontSize;

    this.nameComplementColor = nameComplementColor ?? Consts.stdNameComplementFontColor;
    this.nameComplementFontSize = nameComplementFontSize ?? Consts.stdNameComplementFontSize;
    this.nameComplementFontWeight = nameComplementFontWeight ?? Consts.stdNameComplementFontWeight;
  }

  SiteHeaderText fromMap2(Map<String, dynamic> map) {
    return SiteHeaderText.fromMap(map: map);
  }

  static SiteHeaderText fromMap({required Map<String, dynamic> map}) {
    var u = SiteHeaderText(siteName: Consts.siteName);

    u = SiteHeaderText(
      siteName: map['siteName'] ?? '',
      updateDate: map['updateDate'] == null ? null : DateTime.tryParse(map['updateDate']),
      name: map['name'] ?? '',
      nameFontSize: map['nameFontSize'] ?? Consts.stdNameFontSize,
      nameColor: map['nameColor'] == null ? Consts.stdNameFontColor : Color(map['nameColor']),
      nameFontWeight: map['nameFontWeight'] == null ? Consts.stdNameFontWeight : FontWeight.values[map['nameFontWeight']],
      nameComplement: map['nameComplement'] ?? '',
      nameComplementFontSize: map['nameComplementFontSize'] ?? Consts.stdNameComplementFontSize,
      nameComplementColor:
          map['nameComplementColor'] == null ? Consts.stdNameComplementFontColor : Color(map['nameComplementColor']),
      nameComplementFontWeight: map['nameComplementFontWeight'] == null
          ? Consts.stdNameComplementFontWeight
          : FontWeight.values[map['nameComplementFontWeight']],
      email: map['email'] ?? '',
      urlGitGub: map['urlGitGub'] ?? '',
      urlLinkedin: map['urlLinkedin'] ?? '',
      urlMedium: map['urlMedium'] ?? '',
    );
    return u;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};
    r = {
      'siteName': siteName,
      'updateDate': updateDate.toString(),
      'name': name,
      'NameFontSize': nameFontSize,
      'nameFontWeight': nameFontWeight.index,
      'NameColor': nameColor.value,
      'nameComplement': nameComplement,
      'nameComplementFontSize': nameComplementFontSize,
      'nameComplementColor': nameComplementColor.value,
      'email': email,
      'urlGitGub': urlGitGub,
      'urlLinkedin': urlLinkedin,
      'urlMedium': urlMedium,
    };

    return r;
  }
}
