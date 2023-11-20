import 'package:flutter/material.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/project_data.dart';
import 'package:marcosmhs/features/public_area/visualizations/widgets/area_title.dart';
import 'package:marcosmhs/features/public_area/visualizations/public_area/home_areas/project_data_mobile.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:marcosmhs/features/admin_area/projects/site_project_data.dart';

class ProjectsArea extends StatelessWidget {
  final bool mobile;
  final SiteMainData siteMainData;
  final List<Project> projectList;
  const ProjectsArea({super.key, this.mobile = false, required this.siteMainData, required this.projectList});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        AreaTitle(size: size, title: siteMainData.projectsAreaTitle, siteMainData: siteMainData,),
        ListView.builder(
          shrinkWrap: true,
          itemCount: projectList.length,
          itemBuilder: (context, index) {
            if (mobile) {
              return ProjectDataMobile(
                project: projectList[index],
                siteMainData: siteMainData,
                showDivisor: index != projectList.length - 1,
              );
            } else {
              return ProjectData(
                project: projectList[index],
                siteMainData: siteMainData,
                showDivisor: false,
              );
            }
          },
        ),
      ],
    );
  }
}
