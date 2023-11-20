import 'package:flutter/material.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/about_text.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/articles_area.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/contact_area.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/experience_area.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/header_area_mobile.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/profile_foto_area.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/projects_area.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/admin_area/articles/site_article_data.dart';
import 'package:marcosmhs/features/admin_area/experience/site_experience_data.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_data.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/public_area_data_loader_controller.dart';
import 'package:marcosmhs/features/admin_area/projects/site_project_data.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class HomeMobile extends StatefulWidget {
  final SiteMainData siteMainData;
  const HomeMobile({super.key, required this.siteMainData});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  var _initializing = true;
  var _info = TebUtil.packageInfo;
  var _siteHeader = SiteHeaderText(siteName: '');
  final List<IntroTextData> _introTextDataList = [];
  final List<AboutMeText> _siteAboutMeTextList = [];
  final List<AboutMeTechnology> _siteAboutMeTechnologyList = [];
  late List<Experience> _experienceList = [];
  late List<Article> _articleList = [];
  late List<Project> _projectList = [];
  var _aboutMeData = AboutMeData(siteName: '');

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      TebUtil.version.then((info) => setState(() => _info = info));

      var mainSiteController = PublicAreaDataLoaderController();

      mainSiteController.loadSiteHeader.then((value) {
        setState(() => _siteHeader = value);
      });

      mainSiteController.loadSiteIntroTextList.then((value) {
        _introTextDataList.clear();
        setState(() => _introTextDataList.addAll(value));
      });

      if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty) {
        mainSiteController.loadSiteAboutMeData.then((aboutMeData) {
          _siteAboutMeTextList.clear();
          setState(() => _aboutMeData = aboutMeData);
        });

        mainSiteController.loadSiteAboutMeTextList.then((siteAboutMeList) {
          _siteAboutMeTextList.clear();
          setState(() => _siteAboutMeTextList.addAll(siteAboutMeList));
        });

        mainSiteController.loadSiteAboutMeTechnologyList.then((siteAboutTechList) {
          _siteAboutMeTextList.clear();
          setState(() => _siteAboutMeTechnologyList.addAll(siteAboutTechList));
        });

        if (widget.siteMainData.articleAreaTitle.isNotEmpty) {
          mainSiteController.loadArticleList.then((value) => setState(() => _articleList = value));
        }

        if (widget.siteMainData.projectsAreaTitle.isNotEmpty) {
          mainSiteController.loadProjectList.then((value) => setState(() {
                _projectList = value;
                _projectList.sort((a, b) => b.order.compareTo(a.order));
              }));
        }
      }

      mainSiteController.loadExperienceList.then((value) => setState(() => _experienceList = value));

      _initializing = false;
    }

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: widget.siteMainData.backgroundColor,
      endDrawer: Drawer(
        backgroundColor: widget.siteMainData.backgroundColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
              accountName: Text(_siteHeader.name),
              accountEmail: Text(_siteHeader.email),
            ),
            Expanded(child: Text("v${_info.version}.${_info.buildNumber}"))
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: widget.siteMainData.backgroundColor,
        elevation: 0.0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TebText(
              'That Exotic Bug',
              textSize: 16,
              textColor: widget.siteMainData.specialFontColor.withOpacity(0.7),
              letterSpacing: 1,
              padding: const EdgeInsets.only(left: 12),
            ),
            TebText(
              "v${_info.version}.${_info.buildNumber}",
              textSize: 10,
              textColor: widget.siteMainData.specialFontColor.withOpacity(0.7),
              letterSpacing: 2,
              padding: const EdgeInsets.only(left: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.08),

              HeaderAreaMobile(
                context: context,
                size: size,
                siteMainData: widget.siteMainData,
                siteHeader: _siteHeader,
                introTextDataList: _introTextDataList,
              ),
              SizedBox(height: size.height * 0.05),

              //About me
              if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty)
                AboutText(
                  mobile: true,
                  aboutMeTextList: _siteAboutMeTextList,
                  siteMainData: widget.siteMainData,
                  aboutMeTechnology: _siteAboutMeTechnologyList,
                ),
              if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.05),

              if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty)
                ProfileFotoArea(
                  size: size,
                  context: context,
                  mobile: true,
                  aboutMeData: _aboutMeData,
                  siteMainData: widget.siteMainData,
                ),
              if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.05),

              if (widget.siteMainData.experienceAreaTitle.isNotEmpty)
                ExperienceArea(
                  mobile: true,
                  siteMainData: widget.siteMainData,
                  experienceList: _experienceList,
                ),
              if (widget.siteMainData.experienceAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.07),

              if (widget.siteMainData.articleAreaTitle.isNotEmpty)
                ArticlesArea(
                  mobile: true,
                  siteMainData: widget.siteMainData,
                  articleList: _articleList,
                ),
              if (widget.siteMainData.articleAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.07),

              if (widget.siteMainData.projectsAreaTitle.isNotEmpty)
                ProjectsArea(
                  mobile: true,
                  siteMainData: widget.siteMainData,
                  projectList: _projectList,
                ),
              if (widget.siteMainData.projectsAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.07),

              ContactArea(
                mobile: true,
                siteMainData: widget.siteMainData,
                siteHeader: _siteHeader,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
