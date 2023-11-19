import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/main/routes.dart';
import 'package:marcosmhs/features/site_data/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/site_data/articles/site_article_data.dart';
import 'package:marcosmhs/features/site_data/experience/site_experience_data.dart';
import 'package:marcosmhs/features/site_data/header/site_header_data.dart';
import 'package:marcosmhs/features/site_data/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';
import 'package:marcosmhs/features/site_data/main_site_controller.dart';
import 'package:marcosmhs/features/site_data/projects/site_project_data.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/tabbar_title.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/about_area.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/articles_area.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/contact_area.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/experience_area.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/header_area.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/projects_area.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/social_links.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/url_manager.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class HomeDesktop extends StatefulWidget {
  final SiteMainData siteMainData;
  const HomeDesktop({super.key, required this.siteMainData});

  @override
  State<HomeDesktop> createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  late AutoScrollController _autoScrollController;
  final _scrollDirection = Axis.vertical;
  bool _isExpaned = true;

  var _info = TebUtil.packageInfo;
  var _initializing = true;

  var _siteHeader = SiteHeaderText(siteName: '');
  late List<AboutMeText> _siteAboutMeTextList = [];
  late List<AboutMeTechnology> _siteAboutMeTechnologyList = [];

  late List<Experience> _experienceList = [];
  late List<Article> _articleList = [];
  late List<Project> _projectList = [];
  final List<IntroTextData> _introTextDataList = [];
  var _aboutMeData = AboutMeData(siteName: '');

  bool get _isAppBarExpanded => _autoScrollController.hasClients && _autoScrollController.offset > (160 - kToolbarHeight);

  @override
  void initState() {
    _autoScrollController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: _scrollDirection,
    )..addListener(
        () {
          _isAppBarExpanded
              ? _isExpaned != false
                  ? setState(() => _isExpaned = false)
                  : {}
              : _isExpaned != true
                  ? setState(() => _isExpaned = true)
                  : {};
        },
      );
    super.initState();
  }

  Future _scrollToIndex(int index) async {
    await _autoScrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
    _autoScrollController.highlight(index);
  }

  Widget _wrapScrollTag({required int index, required Widget child}) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: _autoScrollController,
      index: index,
      child: child,
    );
  }

  Widget _navigationBar(Size size) {
    List<Widget> tabList = [];

    if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty) tabList.add(const Tab(child: AppBarTitle(text: 'Sobre')));
    tabList.add(const Tab(child: AppBarTitle(text: 'Trabalho')));
    tabList.add(const Tab(child: AppBarTitle(text: 'Artigos')));
    tabList.add(const Tab(child: AppBarTitle(text: 'Projetos')));
    tabList.add(const Tab(child: AppBarTitle(text: 'Contato')));

    return SizedBox(
      height: size.height * 0.14,
      width: size.width * 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // company and version
            Column(
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
            const Spacer(),
            // menu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DefaultTabController(
                  length: tabList.length,
                  child: TabBar(
                    onTap: (index) async => _scrollToIndex(index),
                    tabs: tabList,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.internalLandingScreen),
              icon: const FaIcon(FontAwesomeIcons.user),
              color: widget.siteMainData.specialFontColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalEmail({required BuildContext context}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.07,
      height: MediaQuery.of(context).size.height - 82,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RotatedBox(
            quarterTurns: 45,
            child: TextButton(
              onPressed: () => UrlManager().launchEmail(),
              child: Text(
                _siteHeader.email,
                style: TextStyle(
                  color: widget.siteMainData.specialFontColor.withOpacity(0.7),
                  letterSpacing: 5.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: 100,
              width: 2,
              color: widget.siteMainData.specialFontColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      TebUtil.version.then((info) => setState(() => _info = info));

      MainSiteController().loadSiteMainData().then((value) => setState(() => widget.siteMainData.fromMap2(value.toMap)));
      MainSiteController().loadSiteHeader().then((value) => setState(() => _siteHeader = value));

      MainSiteController().loadSiteIntroTextList().then((value) {
        _introTextDataList.clear();
        setState(() => _introTextDataList.addAll(value));
      });

      if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty) {
        MainSiteController().loadSiteAboutMeData().then((value) => setState(() => _aboutMeData = value));
        MainSiteController().loadSiteAboutMeTextList().then((value) => setState(() => _siteAboutMeTextList = value));
        MainSiteController().loadSiteAboutMeTechnologyList().then((value) => setState(() => _siteAboutMeTechnologyList = value));
      }
      if (widget.siteMainData.experienceAreaTitle.isNotEmpty) {
        MainSiteController().loadExperienceList().then((value) => setState(() => _experienceList = value));
      }

      if (widget.siteMainData.articleAreaTitle.isNotEmpty) {
        MainSiteController().loadArticleList().then((value) => setState(() => _articleList = value));
      }

      if (widget.siteMainData.projectsAreaTitle.isNotEmpty) {
        MainSiteController().loadProjectList().then((value) => setState(() {
              _projectList = value;
              _projectList.sort((a, b) => a.order.compareTo(b.order));
            }));
      }

      _initializing = false;
    }

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: widget.siteMainData.backgroundColor,
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        primary: true,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            //Navigation Bar
            _navigationBar(size),

            // main
            Row(
              children: [
                SocialLinks(
                  context: context,
                  siteMainData: widget.siteMainData,
                  siteHeader: _siteHeader,
                  size: size,
                ),
                Expanded(
                  child: SizedBox(
                    height: size.height - 82,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomScrollView(
                        controller: _autoScrollController,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              // header
                              HeaderArea(
                                  context: context,
                                  siteMainData: widget.siteMainData,
                                  siteHeader: _siteHeader,
                                  introTextList: _introTextDataList,
                                  size: size),
                              SizedBox(height: size.height * .02),

                              //About
                              if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty)
                                _wrapScrollTag(
                                  index: 0,
                                  child: AboutArea(
                                      siteMainData: widget.siteMainData,
                                      siteAboutMeTextList: _siteAboutMeTextList,
                                      aboutMeData: _aboutMeData,
                                      siteAboutMeTechnologyList: _siteAboutMeTechnologyList),
                                ),
                              if (widget.siteMainData.aboutMeAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.02),

                              //Work experience
                              if (widget.siteMainData.experienceAreaTitle.isNotEmpty)
                                _wrapScrollTag(
                                  index: 1,
                                  child: ExperienceArea(
                                    siteMainData: widget.siteMainData,
                                    experienceList: _experienceList,
                                  ),
                                ),
                              if (widget.siteMainData.experienceAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.02),

                              //Articles
                              if (widget.siteMainData.articleAreaTitle.isNotEmpty)
                                _wrapScrollTag(
                                    index: 2,
                                    child: ArticlesArea(
                                      siteMainData: widget.siteMainData,
                                      articleList: _articleList,
                                    )),
                              if (widget.siteMainData.articleAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.02),

                              //Projects
                              if (widget.siteMainData.projectsAreaTitle.isNotEmpty)
                                _wrapScrollTag(
                                    index: 3,
                                    child: ProjectsArea(
                                      siteMainData: widget.siteMainData,
                                      projectList: _projectList,
                                    )),
                              if (widget.siteMainData.projectsAreaTitle.isNotEmpty) SizedBox(height: size.height * 0.02),

                              //Get In Touch
                              _wrapScrollTag(
                                  index: 4,
                                  child: ContactArea(
                                    siteMainData: widget.siteMainData,
                                    siteHeader: _siteHeader,
                                  )),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _verticalEmail(context: context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
