import 'package:flutter/material.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class AreaTitle extends StatelessWidget {
  final Size size;
  final String title;
  final double? lineWidth;
  final SiteMainData siteMainData;

  const AreaTitle({
    super.key,
    required this.siteMainData,
    required this.size,
    required this.title,
    this.lineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TebText(
              title,
              textSize: 26.0,
              letterSpacing: 4.0,
              textColor: siteMainData.regularFontColor,
              textWeight: FontWeight.w700,
            ),
            SizedBox(width: size.width * 0.01),
            Container(
              width: lineWidth ?? size.width / 4,
              height: 2.50,
              color: Theme.of(context).dividerColor,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.04),
      ],
    );
  }
}
