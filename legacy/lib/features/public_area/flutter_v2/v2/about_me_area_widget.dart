import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/app_theme.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class AboutMeAreaWidget extends StatelessWidget {
  final AboutMeData aboutMeData;
  final List<AboutMeText> aboutMeTextList;
  final List<AboutMeTechnology> aboutMeTechnologyList;

  const AboutMeAreaWidget({
    super.key,
    required this.aboutMeData,
    required this.aboutMeTextList,
    required this.aboutMeTechnologyList,
  });

  Widget _imageWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 320,
          height: 320,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF818CF8), AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: aboutMeData.profilePhotoUrl.isEmpty
                ? Icon(FontAwesomeIcons.user, size: 120, color: Colors.white)
                : ClipOval(
                    child: Image.network(
                      aboutMeData.profilePhotoUrl,
                      width: 320,
                      height: 320,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _textWidget(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    var developmentTechnologiesList = aboutMeTechnologyList
        .where((t) => t.desktop == true && t.type == AboutMeTechnologyType.development)
        .toList();
    var dataScienceTechnologiesList = aboutMeTechnologyList
        .where((t) => t.desktop == true && t.type == AboutMeTechnologyType.dataScience)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sobre Mim', style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: aboutMeTextList.map((siteAboutMeText) {
            return TebText(
              siteAboutMeText.aboutMeText,
              textType: TextType.html,
              fontSize: siteAboutMeText.fontSize,
              fontWeight: siteAboutMeText.fontWeight,
              padding: const EdgeInsets.only(bottom: 10),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        TebText('Desenvolvimento', fontWeight: FontWeight.bold),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: developmentTechnologiesList.map((tech) {
            return Chip(
              label: TebText(tech.technologyName, fontColor: AppColors.primary),
              backgroundColor: AppColors.primary.withAlpha(40),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        TebText('Data Science', fontWeight: FontWeight.bold),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: dataScienceTechnologiesList.map((tech) {
            return Chip(
              label: TebText(tech.technologyName, fontColor: AppColors.primary),
              backgroundColor: AppColors.primary.withAlpha(40),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double breakpoint = 960.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Layout para telas largas (Desktop)
              if (constraints.maxWidth > breakpoint) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 6, child: _textWidget(context)),
                    const SizedBox(width: 48),
                    Expanded(flex: 4, child: _imageWidget(context)),
                  ],
                );
              }
              // Layout para telas estreitas (Mobile)
              else {
                return Column(
                  children: [
                    _textWidget(context),
                    const SizedBox(height: 60),
                    _imageWidget(context),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
