import 'package:flutter/material.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_desktop.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_mobile.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/public_area_data_loader_controller.dart';
//import 'package:marcosmhs/features/main/visualizations/public_area/internal_landing_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  var _siteMainData = SiteMainData(siteName: '');
  var _initializing = true;

  @override
  Widget build(BuildContext context) {
    if (_initializing == true) {
      PublicAreaDataLoaderController().loadSiteMainData.then((value) {
        setState(() => _siteMainData = value);
      });
      _initializing = false;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        //return const InternalLandingScreen();
        FirebaseAnalytics analytics = FirebaseAnalytics.instance;
        if (constraints.maxWidth >= 1000) {
          analytics.logEvent(name: 'login_desktop');
          return HomeDesktop(siteMainData: _siteMainData);
        } else {
          analytics.logEvent(name: 'login_mobile');
          return HomeMobile(siteMainData: _siteMainData);
        }
      },
    );
  }
}
