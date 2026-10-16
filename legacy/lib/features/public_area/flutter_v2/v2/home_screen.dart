import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/admin_area/articles/article_data.dart';
import 'package:marcosmhs/features/admin_area/experience/experience_data.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_data.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/public_area/v2/about_me_area_widget.dart';
import 'package:marcosmhs/features/public_area/v2/app_bar_widget.dart';
import 'package:marcosmhs/features/public_area/v2/articles_area_widget.dart';
import 'package:marcosmhs/features/public_area/v2/contact_area_widget.dart';
import 'package:marcosmhs/features/public_area/v2/experience_area_widget.dart';
import 'package:marcosmhs/features/public_area/v2/hero_area_widget.dart';
import 'package:marcosmhs/features/public_area/v2/projects_area_widget.dart';
import 'package:marcosmhs/features/public_area/public_area_data_loader_controller.dart';

import 'package:teb_package/screen_widgets/teb_scaffold.dart';
import 'package:teb_package/util/teb_util.dart';

import '../../admin_area/projects/project_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Map<String, GlobalKey> sectionKeys;
  var _info = TebUtil.packageInfo;

  // Chaves para cada seção para permitir o scroll
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey experienceKey = GlobalKey();
  final GlobalKey articlesKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  //Dados dinâmicos
  var _siteHeaderText = SiteHeaderText(siteName: '');
  final List<IntroTextData> _introTextDataList = [];
  var _aboutMeData = AboutMeData(siteName: '');
  late List<AboutMeText> _aboutMeTextList = [];
  late List<AboutMeTechnology> _aboutMeTechnologyList = [];
  late List<Experience> _experienceList = [];
  late List<Article> _articleList = [];
  late List<Project> _projectList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    sectionKeys = {
      'Sobre': aboutKey,
      'Experiência': experienceKey,
      'Artigos': articlesKey,
      'Projetos': projectsKey,
      'Contato': contactKey,
    };
  }

  void _scrollToSection(GlobalKey key) {
    final sectionContext = key.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  void _loadData() {
    TebUtil.version.then((info) => _safeSetState(() => _info = info));

    var mainSiteController = PublicAreaDataLoaderController();

    mainSiteController.loadSiteHeader.then((value) => _safeSetState(() => _siteHeaderText = value));

    mainSiteController.loadSiteIntroTextList.then((value) {
      _introTextDataList.clear();
      _safeSetState(() => _introTextDataList.addAll(value));
    });

    mainSiteController.loadSiteAboutMeData.then(
      (value) => _safeSetState(() => _aboutMeData = value),
    );
    mainSiteController.loadSiteAboutMeTextList.then(
      (value) => _safeSetState(() => _aboutMeTextList = value),
    );
    mainSiteController.loadSiteAboutMeTechnologyList.then(
      (value) => _safeSetState(() => _aboutMeTechnologyList = value),
    );

    mainSiteController.loadExperienceList.then(
      (value) => _safeSetState(() => _experienceList = value),
    );

    mainSiteController.loadArticleList.then(
      (articleList) => _safeSetState(() {
        articleList.sort((a, b) => a.order.compareTo(b.order));
        _articleList = articleList;
      }),
    );

    mainSiteController.loadProjectList.then(
      (projectList) => _safeSetState(() {
        projectList.sort((a, b) => b.order.compareTo(a.order));
        _projectList = projectList;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TebScaffold(
      title: AppBarWidget(
        sectionKeys: sectionKeys,
        onNavigate: _scrollToSection,
        title: 'That Exotic Bug',
        version: "v${_info.version}.${_info.buildNumber}",
      ),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                HeroAreaWidget(
                  siteHeaderText: _siteHeaderText,
                  introTextDataList: _introTextDataList,
                  onNavigate: () => _scrollToSection(aboutKey),
                ),
                AboutMeAreaWidget(
                  key: aboutKey,
                  aboutMeData: _aboutMeData,
                  aboutMeTextList: _aboutMeTextList,
                  aboutMeTechnologyList: _aboutMeTechnologyList,
                ),
                ExperienceSection(key: experienceKey, experienceList: _experienceList),
                ArticlesAreaWidget(key: articlesKey, articleList: _articleList),
                ProjectsAreaWidget(key: projectsKey, projectsList: _projectList),
                ContactAreaWidget(key: contactKey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
