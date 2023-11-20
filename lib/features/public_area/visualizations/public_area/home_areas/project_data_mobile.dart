import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/public_area/visualizations/widgets/url_manager.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:marcosmhs/features/admin_area/projects/site_project_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class ProjectDataMobile extends StatelessWidget {
  final SiteMainData siteMainData;
  final Project project;
  final bool showDivisor;

  const ProjectDataMobile({super.key, required this.project, required this.siteMainData, this.showDivisor = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TebText(
          project.title,
          textSize: 27,
          textColor: siteMainData.regularFontColor,
          textWeight: FontWeight.w700,
          letterSpacing: 1.75,
          padding: const EdgeInsets.only(bottom: 10),
        ),

        // Image
        Image.network(
          project.externalImageUrl.isNotEmpty ? project.externalImageUrl : project.firestorageImageUrl,
          fit: BoxFit.contain,
        ),

        // Project Resources
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TebText(project.tag1, textSize: 16, textColor: siteMainData.regularFontColor, letterSpacing: 1.75),
                TebText(project.tag2, textSize: 16, textColor: siteMainData.regularFontColor, letterSpacing: 1.75),
                TebText(project.tag3, textSize: 16, textColor: siteMainData.regularFontColor, letterSpacing: 1.75),
              ],
            ),
            const Spacer(),
            Row(
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
            )
          ],
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
    );
  }
}
