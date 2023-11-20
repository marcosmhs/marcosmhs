import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_controller.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/admin_area/articles/site_article_controller.dart';
import 'package:marcosmhs/features/admin_area/articles/site_article_data.dart';
import 'package:marcosmhs/features/admin_area/experience/site_experience_controller.dart';
import 'package:marcosmhs/features/admin_area/experience/site_experience_data.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_controller.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_data.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text_controller.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data_controller.dart';
import 'package:marcosmhs/features/admin_area/projects/site_project_controller.dart';
import 'package:marcosmhs/features/admin_area/projects/site_project_data.dart';

class PublicAreaDataLoaderController {
  Future<SiteMainData> get loadSiteMainData async {
    return await SiteMainDataController().getData(siteName: Consts.siteName);
  }

  Future<SiteHeaderText> get loadSiteHeader async {
    return await SiteHeaderController().getData(siteName: Consts.siteName);
  }

  Future<List<IntroTextData>> get loadSiteIntroTextList async {
    return await SiteIntroTextController().getData(siteName: Consts.siteName);
  }

  Future<AboutMeData> get loadSiteAboutMeData async {
    return await SiteAboutMeController().getAboutMeData(siteName: Consts.siteName);
  }

  Future<List<AboutMeText>> get loadSiteAboutMeTextList async {
    return await SiteAboutMeController().getAboutMeTextListData(siteName: Consts.siteName);
  }

  Future<List<AboutMeTechnology>> get loadSiteAboutMeTechnologyList async {
    return await SiteAboutMeController().getAboutMeTechnologyListData(siteName: Consts.siteName);
  }

  Future<List<Experience>> get loadExperienceList async {
    return await ExperienceController().getData(siteName: Consts.siteName);
  }

  Future<List<Article>> get loadArticleList async {
    return await ArticlesController().getData(siteName: Consts.siteName);
  }

  Future<List<Project>> get loadProjectList async {
    return await ProjectsController().getData(siteName: Consts.siteName);
  }
}
