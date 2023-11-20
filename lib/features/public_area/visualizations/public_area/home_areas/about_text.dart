import 'package:flutter/material.dart';
import 'package:marcosmhs/features/public_area/visualizations/widgets/area_title.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class AboutText extends StatefulWidget {
  final bool mobile;
  final List<AboutMeText> aboutMeTextList;
  final SiteMainData siteMainData;
  final List<AboutMeTechnology> aboutMeTechnology;
  const AboutText({
    super.key,
    this.mobile = false,
    required this.aboutMeTextList,
    required this.siteMainData,
    required this.aboutMeTechnology,
  });

  @override
  State<AboutText> createState() => _AboutTextState();
}

class _AboutTextState extends State<AboutText> {
  Color? customImageColor;

  Widget _technology(BuildContext context, String text, bool title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: title ? 6.0 : 2.0),
      child: Row(
        children: [
          Icon(Icons.skip_next, color: widget.siteMainData.specialFontColor.withOpacity(0.6), size: 14.0),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          TebText(
            text,
            textColor: widget.siteMainData.regularFontColor,
            textWeight: title ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 1.75,
          )
        ],
      ),
    );
  }

  Widget _tecnologies(Size size, BuildContext context) {
    var technologiesDevelopment =
        widget.aboutMeTechnology.where((t) => t.desktop == true && t.type == AboutMeTechnologyType.development).toList();
    var technologiesDataScience =
        widget.aboutMeTechnology.where((t) => t.desktop == true && t.type == AboutMeTechnologyType.dataScience).toList();

    if (widget.mobile) {
      technologiesDevelopment =
          widget.aboutMeTechnology.where((t) => t.mobile == true && t.type == AboutMeTechnologyType.development).toList();
      technologiesDataScience =
          widget.aboutMeTechnology.where((t) => t.mobile == true && t.type == AboutMeTechnologyType.dataScience).toList();
    }

    return Wrap(
      children: [
        SizedBox(
          width: widget.mobile ? size.width * 0.45 : size.width * 0.20,
          child: Column(
            children: [
              _technology(context, 'Desenvolvimento', true),
              ListView.builder(
                shrinkWrap: true,
                itemCount: technologiesDevelopment.length,
                itemBuilder: (context, index) {
                  return _technology(context, technologiesDevelopment[index].technologyName, false);
                },
              ),
            ],
          ),
        ),
        SizedBox(
          width: widget.mobile ? size.width * 0.45 : size.width * 0.21,
          child: Column(
            children: [
              _technology(context, 'Data Science', true),
              ListView.builder(
                shrinkWrap: true,
                itemCount: technologiesDataScience.length,
                itemBuilder: (context, index) {
                  return _technology(context, technologiesDataScience[index].technologyName, false);
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    List<AboutMeText> aboutMeTextList = [];

    if (widget.mobile) {
      aboutMeTextList = widget.aboutMeTextList.where((a) => a.mobile == true).toList();
    } else {
      aboutMeTextList = widget.aboutMeTextList.where((a) => a.desktop == true).toList();
    }

    return Column(
      children: [
        AreaTitle(size: size, title: widget.siteMainData.aboutMeAreaTitle, siteMainData: widget.siteMainData),

        // about text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: aboutMeTextList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TebText(
                    aboutMeTextList[index].aboutMeText,
                    textSize: aboutMeTextList[index].fontSize,
                    letterSpacing: 1,
                    textColor: aboutMeTextList[index].fontColor,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                );
              },
            ),
          ],
        ),

        // technolodies
        _tecnologies(size, context)
      ],
    );
  }
}
