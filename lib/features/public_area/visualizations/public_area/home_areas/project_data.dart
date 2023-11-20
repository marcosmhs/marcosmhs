import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/public_area/visualizations/widgets/url_manager.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:marcosmhs/features/admin_area/projects/site_project_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class ProjectData extends StatelessWidget {
  final Project project;
  final SiteMainData siteMainData;
  final bool showDivisor;

  const ProjectData({
    super.key,
    required this.project,
    required this.siteMainData,
    this.showDivisor = true,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.68,
      width: size.width - 100,
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.68,
            width: size.width - 84,
            child: Stack(
              children: [
                // Image
                Positioned(
                  top: size.height * 0.02,
                  left: 20.0,
                  child: SizedBox(
                    height: size.height * 0.60,
                    width: size.width * 0.5,
                    child: Image.network(
                      project.externalImageUrl.isNotEmpty ? project.externalImageUrl : project.firestorageImageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Project Title
                Positioned(
                  top: 16.0,
                  right: 10.0,
                  child: SizedBox(
                    height: size.height * 0.10,
                    width: size.width * 0.25,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        TebText(
                          project.title,
                          textSize: 27,
                          textColor: siteMainData.regularFontColor,
                          textWeight: FontWeight.w700,
                          letterSpacing: 1.75,
                        ),
                      ],
                    ),
                  ),
                ),

                // Short Desc
                Positioned(
                  top: size.height / 6,
                  right: 10.0,
                  child: Container(
                    alignment: Alignment.center,
                    height: size.height * 0.18,
                    width: size.width * 0.35,
                    color: siteMainData.secundaryBackgroundColor,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TebText(
                            project.description,
                            textSize: 18.0,
                            textColor: siteMainData.regularFontColor,
                            letterSpacing: 0.75,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Project Resources
                Positioned(
                  top: size.height * 0.36,
                  right: 10.0,
                  child: SizedBox(
                    height: size.height * 0.08,
                    width: size.width * 0.25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TebText(project.tag1, textSize: 16, textColor: siteMainData.regularFontColor, letterSpacing: 1.75),
                        const SizedBox(width: 16.0),
                        TebText(project.tag2, textSize: 16, textColor: siteMainData.regularFontColor, letterSpacing: 1.75),
                        const SizedBox(width: 16.0),
                        TebText(project.tag3, textSize: 16, textColor: siteMainData.regularFontColor, letterSpacing: 1.75),
                      ],
                    ),
                  ),
                ),

                // Links
                Positioned(
                  top: size.height * 0.42,
                  right: 10.0,
                  child: SizedBox(
                    height: size.height * 0.08,
                    width: size.width * 0.25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            project.urlGithub.isNotEmpty
                                ? IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.github),
                                    color: siteMainData.regularFontColor,
                                    onPressed: () => UrlManager().launchUrl(url: project.urlGithub),
                                  )
                                : const Text(''),
                            project.url.isNotEmpty
                                ? IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.link),
                                    color: siteMainData.regularFontColor,
                                    onPressed: () => UrlManager().launchUrl(url: project.url),
                                  )
                                : const Text(''),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivisor)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                height: 1.00,
                color: siteMainData.regularFontColor,
              ),
            ),
        ],
      ),
    );
  }
}
