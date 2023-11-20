import 'package:flutter/material.dart';
import 'package:marcosmhs/features/public_area/visualizations/widgets/url_manager.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_data.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class HeaderAreaMobile extends StatefulWidget {
  final SiteHeaderText siteHeader;
  final SiteMainData siteMainData;
  final List<IntroTextData> introTextDataList;

  const HeaderAreaMobile({
    super.key,
    required this.context,
    required this.size,
    required this.siteHeader,
    required this.siteMainData,
    required this.introTextDataList,
  });

  final BuildContext context;
  final Size size;

  @override
  State<HeaderAreaMobile> createState() => _HeaderAreaMobileState();
}

class _HeaderAreaMobileState extends State<HeaderAreaMobile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // name
        TebText(
          widget.siteHeader.name,
          textSize: widget.siteHeader.nameFontSize,
          textColor: widget.siteHeader.nameColor.withOpacity(0.75),
          textWeight: widget.siteHeader.nameFontWeight,
          padding: EdgeInsets.only(bottom: widget.size.height * 0.02),
        ),

        // name complement
        TebText(
          widget.siteHeader.nameComplement,
          textSize: widget.siteHeader.nameComplementFontSize,
          textColor: widget.siteHeader.nameComplementColor,
          textWeight: widget.siteHeader.nameComplementFontWeight,
          padding: EdgeInsets.only(bottom: widget.size.height * 0.02),
        ),

        // intro text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.introTextDataList.where((i) => i.mobile == true).length,
              itemBuilder: (context, index) {
                return TebText(
                  widget.introTextDataList.where((i) => i.mobile == true).toList()[index].introText,
                  textSize: widget.introTextDataList.where((i) => i.mobile == true).toList()[index].fontSize,
                  letterSpacing: 2.75,
                  wordSpacing: 0.75,
                  textColor: widget.introTextDataList.where((i) => i.mobile == true).toList()[index].fontColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                );
              },
            ),
          ],
        ),

        // contact button
        InkWell(
          onTap: () => UrlManager().launchEmail(),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
            color: widget.siteMainData.specialColor,
            child: Container(
              margin: const EdgeInsets.all(0.85),
              height: widget.size.height * 0.08,
              width: widget.size.width * 0.45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.siteMainData.backgroundColor,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: TebText(
                "Entrar em contato",
                textColor: widget.siteMainData.specialColor,
                textAlign: TextAlign.center,
                letterSpacing: 3,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
