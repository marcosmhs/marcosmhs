import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/public_area/v2/widgets/card_hover_widget.dart';
import 'package:marcosmhs/features/public_area/v2/widgets/card_image_widget.dart';
import 'package:marcosmhs/features/public_area/url_manager.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

import '../../admin_area/projects/project_data.dart';

class ProjectsAreaWidget extends StatelessWidget {
  final List<Project> projectsList;
  const ProjectsAreaWidget({super.key, required this.projectsList});

  Widget _buttonsWidget({required Project project}) {
    return Row(
      children: [
        if (project.urlGithub.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () => UrlManager.launchUrl(url: project.urlGithub),
            icon: const Icon(FontAwesomeIcons.github, size: 16),
            label: const TebText('GitHub', fontColor: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F2937)),
          ),
        if (project.urlGithub.isNotEmpty && project.url.isNotEmpty) const SizedBox(width: 12),
        if (project.url.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () => UrlManager.launchUrl(url: project.url),
            icon: const Icon(FontAwesomeIcons.link, size: 16),
            label: const TebText('Acessar', fontColor: Colors.white),
          ),
      ],
    );
  }

  Widget _projectCardWidget({required BuildContext context, required Project project}) {
    final Color colorSeed = cardColorSeed(project.title);

    List<String> tagsList = [];
    if (project.tag1.isNotEmpty) tagsList.add(project.tag1);
    if (project.tag2.isNotEmpty) tagsList.add(project.tag2);
    if (project.tag3.isNotEmpty) tagsList.add(project.tag3);

    return HoverCardWidget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorSeed.withAlpha(50), colorSeed.withAlpha(150)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Center(
                child: CardImageWidget(
                  url: project.externalImageUrl.isNotEmpty
                      ? project.externalImageUrl
                      : project.firestorageImageUrl,
                  fit: BoxFit.contain,
                  color: colorSeed,
                ),
              ),
            ),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TebText(project.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TebText(
                    project.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: tagsList.map((tag) {
                      return Chip(
                        label: TebText(tag),
                        backgroundColor: colorSeed.withAlpha(40),
                        labelStyle: TextStyle(
                          color: colorSeed,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buttonsWidget(project: project),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TebText(
                'Projetos Técnicos',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 64),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  if (constraints.maxWidth >= 768) {
                    crossAxisCount = 2;
                  } else {
                    crossAxisCount = 1;
                  }

                  const double gap = 32.0;
                  final double itemWidth =
                      (constraints.maxWidth - (gap * (crossAxisCount - 1))) / crossAxisCount;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: projectsList.map((project) {
                      return SizedBox(
                        width: itemWidth,
                        child: _projectCardWidget(context: context, project: project),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
