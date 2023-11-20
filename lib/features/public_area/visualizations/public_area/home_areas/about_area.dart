import 'package:flutter/material.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/about_text.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/profile_foto_area.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';

class AboutArea extends StatefulWidget {
  final bool mobile;
  final SiteMainData siteMainData;
  final AboutMeData aboutMeData;
  final List<AboutMeText> siteAboutMeTextList;
  final List<AboutMeTechnology> siteAboutMeTechnologyList;
  const AboutArea({
    super.key,
    this.mobile = false,
    required this.siteMainData,
    required this.aboutMeData,
    required this.siteAboutMeTextList,
    required this.siteAboutMeTechnologyList,
  });

  @override
  State<AboutArea> createState() => _AboutAreaState();
}

class _AboutAreaState extends State<AboutArea> {
  Color? customImageColor;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width - 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width / 2 - 100,
            child: AboutText(
              mobile: widget.mobile,
              siteMainData: widget.siteMainData,
              aboutMeTextList: widget.siteAboutMeTextList,
              aboutMeTechnology: widget.siteAboutMeTechnologyList,
            ),
          ),

          //Profile Image
          ProfileFotoArea(
            size: size,
            context: context,
            aboutMeData: widget.aboutMeData,
            siteMainData: widget.siteMainData,
          ),
        ],
      ),
    );
  }
}
