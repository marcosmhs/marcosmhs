//import 'dart:convert';
//import 'package:flutter/services.dart';
//import 'package:json_theme/json_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:marcosmhs/features/admin_area/user/login_screen.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:marcosmhs/features/admin_area/user/user_form.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:marcosmhs/theme_data.dart';
//import 'package:marcosmhs/features/main/theme_data.dart';
import 'package:marcosmhs/internal_landing_screen.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/landing_screen.dart';
import 'package:marcosmhs/features/admin_area/main_area.dart';
import 'package:marcosmhs/features/screen_not_found.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_form.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_technologies_form.dart';
import 'package:marcosmhs/features/admin_area/articles/site_article_form.dart';
import 'package:marcosmhs/features/admin_area/experience/site_experience_form.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text_form.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data_form.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_form.dart';
import 'package:marcosmhs/features/admin_area/projects/site_project_form.dart';
import 'firebase_options.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

class XDPathUrlStrategy extends HashUrlStrategy {
  // Creates an instance of [PathUrlStrategy].
  // The [PlatformLocation] parameter is useful for testing to mock out browser interactions.
  XDPathUrlStrategy([
    super.platformLocation,
  ]) : _basePath = stripTrailingSlash(extractPathname(checkBaseHref(
          platformLocation.getBaseHref(),
        )));

  final String _basePath;

  @override
  String prepareExternalUrl(String internalUrl) {
    if (internalUrl.isNotEmpty && !internalUrl.startsWith('/')) {
      internalUrl = '/$internalUrl';
    }
    return '$_basePath/';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //var themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  //var themeJson = json.decode(themeStr);
  //var themeData = ThemeDecoder.decodeThemeData(
  //      themeJson,
  //      validate: true,
  //    ) ??
  //    ThemeData();

  //setUrlStrategy(XDPathUrlStrategy());
  runApp(Marcosmhs(themeData: ThemeData()));
}

class Marcosmhs extends StatefulWidget {
  final ThemeData themeData;

  const Marcosmhs({Key? key, required this.themeData}) : super(key: key);

  @override
  State<Marcosmhs> createState() => _Home();
}

class _Home extends State<Marcosmhs> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt-br', ''),
      ],
      title: 'Marcos Silva',
      routes: {
        Routes.landingScreen: (ctx) => const LandingScreen(),
        Routes.loginScreen: (ctx) => const LoginScreen(mobile: true),
        Routes.mainScreen: (ctx) => const MainArea(),
        Routes.userForm: (ctx) => const UserForm(),
        Routes.internalLandingScreen: (ctx) => const InternalLandingScreen(),
        Routes.siteHeaderTextForm: (ctx) => const SiteHeaderTextForm(),
        Routes.siteMainData: (ctx) => const SiteMainDataForm(),
        Routes.siteIntroTextForm: (ctx) => const SiteIntroTextForm(),
        Routes.siteAboutMeTextForm: (ctx) => const SiteAboutMeTextForm(),
        Routes.siteAboutMeTechnologiesForm: (ctx) => const SiteAboutMeTechnologiestForm(),
        Routes.experienceForm: (ctx) => const ExperienceForm(),
        Routes.articleForm: (ctx) => const ArticleForm(),
        Routes.projectForm: (ctx) => const ProjectForm(),
      },
      theme: thatExoticBugTheme,
      //theme: widget.themeData,
      //themeMode: ThemeMode.dark,
      initialRoute: Routes.landingScreen,
      // Executado quando uma tela não é encontrada
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) {
          return ScreenNotFound(settings.name.toString());
        });
      },
    );
  }
}
