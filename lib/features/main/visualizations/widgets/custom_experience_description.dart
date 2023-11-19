import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/site_data/experience/site_experience_data.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class CustomExperienceDescription extends StatelessWidget {
  final Experience experience;
  final SiteMainData siteMainData;
  final bool mobile;
  final Size size;

  const CustomExperienceDescription({
    Key? key,
    required this.experience,
    required this.size,
    this.mobile = false,
    required this.siteMainData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: experience.iconBackgroundColor,
          radius: mobile ? null : 35,
          child: FaIcon(
            experience.iconData,
            color: experience.iconColor,
            size: mobile ? null : 35,
          ),
        ),
        SizedBox(width: mobile ? 10 : 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TebText(
              experience.title,
              textSize: mobile ? 16 : 28,
              textWeight: FontWeight.w500,
              letterSpacing: 4,
              textColor: siteMainData.regularFontColor.withOpacity(0.7),
            ),
            const SizedBox(height: 8.0),
            TebText(
              experience.company,
              textSize: mobile ? 14 : 16,
              textWeight: FontWeight.w400,
              textColor: siteMainData.regularFontColor,
              padding: mobile ? const EdgeInsets.only(left: 12) : null,
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: mobile ? size.width * 0.78 : size.width * 0.60,
              child: TebText(
                experience.description,
                textSize: mobile ? 14 : 16,
                textWeight: FontWeight.w400,
                textColor: siteMainData.regularFontColor,
                padding: mobile ? const EdgeInsets.only(left: 12) : null,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8.0),
            TebText(
              experience.durationStart,
              textSize: mobile ? 12 : 14,
              textColor: siteMainData.regularFontColor,
              padding: mobile ? const EdgeInsets.only(left: 12, bottom: 12) : const EdgeInsets.only(bottom: 30),
            ),
          ],
        ),
      ],
    );
  }
}
