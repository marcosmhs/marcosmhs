import 'package:flutter/material.dart';
import 'package:marcosmhs/app_theme.dart';
import 'package:marcosmhs/features/admin_area/header/site_header_data.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class HeroAreaWidget extends StatelessWidget {
  final SiteHeaderText siteHeaderText;
  final List<IntroTextData> introTextDataList;
  final VoidCallback onNavigate;
  const HeroAreaWidget({
    super.key,
    required this.siteHeaderText,
    required this.introTextDataList,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TebText(
                siteHeaderText.name,
                textAlign: TextAlign.center,
                fontSize: siteHeaderText.nameFontSize,
                fontWeight: siteHeaderText.nameFontWeight,
                fontColor: Colors.white,
              ),
              const SizedBox(height: 24),
              TebText(
                siteHeaderText.nameComplement,
                textAlign: TextAlign.center,
                fontSize: siteHeaderText.nameComplementFontSize,
                fontWeight: siteHeaderText.nameComplementFontWeight,
                fontColor: Colors.white70,
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: introTextDataList.map((introTextData) {
                  return TebText(
                    introTextData.introText,
                    textType: TextType.html,
                    fontSize: introTextData.fontSize,
                    fontWeight: introTextData.fontWeight,
                    fontColor: Colors.white60,
                    padding: EdgeInsets.only(bottom: 10),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
