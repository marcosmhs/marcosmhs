import 'package:flutter/material.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/custom_experience_description.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/area_title.dart';
import 'package:marcosmhs/features/site_data/experience/site_experience_data.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';

class ExperienceArea extends StatefulWidget {
  final bool mobile;
  final List<Experience> experienceList;
  final SiteMainData siteMainData;
  const ExperienceArea({
    super.key,
    this.mobile = false,
    required this.experienceList,
    required this.siteMainData,
  });

  @override
  State<ExperienceArea> createState() => _ExperienceAreaState();
}

class _ExperienceAreaState extends State<ExperienceArea> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        AreaTitle(
          size: size,
          title: widget.siteMainData.experienceAreaTitle,
          siteMainData: widget.siteMainData,
          lineWidth: widget.mobile ? 0 : null,
        ),
        Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: widget.experienceList.length,
              itemBuilder: (context, index) {
                return CustomExperienceDescription(
                  siteMainData: widget.siteMainData,
                  experience: widget.experienceList[index],
                  mobile: widget.mobile,
                  size: size,
                );
              },
            ),
            if (!widget.mobile) const SizedBox(height: 100),
          ],
        ),
      ],
    );
  }
}
