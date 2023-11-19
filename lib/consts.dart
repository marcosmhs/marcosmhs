import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/main/theme_data.dart';

class Consts {
  static String get siteName => 'marcosmhs';

  static Color get stdBackgroundColor => thatExoticBugTheme.colorScheme.background;
  static Color get stdSpecialColor => thatExoticBugTheme.colorScheme.secondary;
  static Color get stdRegularFontColor => thatExoticBugTheme.primaryColorLight;
  static Color get stdSpecialFontColor => thatExoticBugTheme.colorScheme.primary;

  static double get stdNameFontSize => 68;
  static FontWeight get stdNameFontWeight => FontWeight.w900;
  static Color get stdNameFontColor => thatExoticBugTheme.colorScheme.primary;

  static double get stdNameComplementFontSize => 45;
  static FontWeight get stdNameComplementFontWeight => FontWeight.w700;
  static Color get stdNameComplementFontColor => thatExoticBugTheme.colorScheme.secondaryContainer;

  static double get stdIntroTextFontSize => 16;
  static FontWeight get stdIntroTextFontWeight => FontWeight.w400;
  static Color get stdIntroTextFontColor => thatExoticBugTheme.primaryColorLight;

  static IconData get stdExperienceIconData => FontAwesomeIcons.solidMessage;
  static Color get stdExperienceBackgroundIconColor => Colors.redAccent;
  static Color get stdExperienceIconColor => Colors.white;

  static String get stdAboutMeAreaTitle => 'Sobre mim';
  static String get stdExperienceAreaTitle => 'Minha experiência profissional';
  static String get stdArticleAreaTitle => 'Artigos escritos';
  static String get stdProjectsAreaTitle => 'Projetos recentes';
}

class FirebaseConsts {
  static String get mainDataCollectionName => 'mainData';

  static String get headerTextCollectionName => 'headerText';

  static String get introTextCollectionName => 'introText';

  static String get aboutMeDataCollectionName => 'aboutMeData';
  static String get aboutMeTextCollectionName => 'aboutMeText';
  static String get aboutMeTechnologyCollectionName => 'aboutMeTechnology';

  static String get experienceCollectionName => 'experience';
  static String get articleCollectionName => 'article';
  static String get projectCollectionName => 'project';
}
