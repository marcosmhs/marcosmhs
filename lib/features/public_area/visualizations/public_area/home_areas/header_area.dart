import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_data.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class HeaderArea extends StatefulWidget {
  final Size size;
  final BuildContext context;
  final SiteMainData siteMainData;
  final SiteHeaderText siteHeader;
  final List<IntroTextData> introTextList;

  const HeaderArea({
    super.key,
    required this.context,
    required this.siteMainData,
    required this.siteHeader,
    required this.introTextList,
    required this.size,
  });

  @override
  State<HeaderArea> createState() => _HeaderAreaState();
}

class _HeaderAreaState extends State<HeaderArea> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        TebText(
          widget.siteHeader.name,
          textSize: 68.0,
          textColor: widget.siteHeader.nameColor.withOpacity(0.75),
          textWeight: widget.siteHeader.nameFontWeight,
          padding: EdgeInsets.only(top: widget.size.height * .06),
        ),

        // name complement
        TebText(
          widget.siteHeader.nameComplement,
          textSize: 45.0,
          textColor: widget.siteHeader.nameComplementColor,
          textWeight: widget.siteHeader.nameComplementFontWeight,
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),

        // intro text
        Padding(
          padding: EdgeInsets.only(top: widget.size.height * .04),
          child: SizedBox(
            width: widget.size.width * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.introTextList.where((e) => e.desktop == true).toList().length,
                  itemBuilder: (context, index) {
                    return TebText(
                      widget.introTextList.where((e) => e.desktop == true).toList()[index].introText,
                      textSize: widget.introTextList.where((e) => e.desktop == true).toList()[index].fontSize,
                      letterSpacing: 2.75,
                      wordSpacing: 0.75,
                      textColor: widget.introTextList.where((e) => e.desktop == true).toList()[index].fontColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
