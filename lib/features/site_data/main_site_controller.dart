import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/site_data/about_me/site_about_me_controller.dart';
import 'package:marcosmhs/features/site_data/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/site_data/articles/site_article_controller.dart';
import 'package:marcosmhs/features/site_data/articles/site_article_data.dart';
import 'package:marcosmhs/features/site_data/experience/site_experience_controller.dart';
import 'package:marcosmhs/features/site_data/experience/site_experience_data.dart';
import 'package:marcosmhs/features/site_data/header/site_header_controller.dart';
import 'package:marcosmhs/features/site_data/header/site_header_data.dart';
import 'package:marcosmhs/features/site_data/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/site_data/intro_text/site_intro_text_controller.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data_controller.dart';
import 'package:marcosmhs/features/site_data/projects/site_project_controller.dart';
import 'package:marcosmhs/features/site_data/projects/site_project_data.dart';

class MainSiteController {
  Future<SiteMainData> loadSiteMainData() async {
    return await SiteMainDataController().getData(siteName: Consts.siteName);
  }

  Future<SiteHeaderText> loadSiteHeader() async {
    return await SiteHeaderController().getData(siteName: Consts.siteName);
  }

  Future<List<IntroTextData>> loadSiteIntroTextList() async {
    return await SiteIntroTextController().getData(siteName: Consts.siteName);
  }

  Future<AboutMeData> loadSiteAboutMeData() async {
    return await SiteAboutMeController().getAboutMeData(siteName: Consts.siteName);
  }

  Future<List<AboutMeText>> loadSiteAboutMeTextList() async {
    return await SiteAboutMeController().getAboutMeTextListData(siteName: Consts.siteName);
  }

  Future<List<AboutMeTechnology>> loadSiteAboutMeTechnologyList() async {
    return await SiteAboutMeController().getAboutMeTechnologyListData(siteName: Consts.siteName);
  }

  Future<List<Experience>> loadExperienceList() async {
    return await ExperienceController().getData(siteName: Consts.siteName);
  }

  Future<List<Article>> loadArticleList() async {
    return await ArticlesController().getData(siteName: Consts.siteName);
  }

  Future<List<Project>> loadProjectList() async {
    return await ProjectsController().getData(siteName: Consts.siteName);
  }
}
