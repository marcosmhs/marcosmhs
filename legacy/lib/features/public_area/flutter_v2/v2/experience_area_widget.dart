import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/experience/experience_data.dart';
import 'package:marcosmhs/features/public_area/v2/widgets/card_hover_widget.dart';

class ExperienceSection extends StatelessWidget {
  final List<Experience> experienceList;
  const ExperienceSection({super.key, required this.experienceList});

  String _periodText(Experience experience) {
    if (experience.durationEnd.isEmpty) return experience.durationStart;
    return '${experience.durationStart} - ${experience.durationEnd}';
  }

  Widget _titleAndCompanyNameWidget({
    required Experience experience,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(experience.title, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          experience.company,
          style: textTheme.bodyLarge!.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _iconWidget({required Experience experience}) {
    return CircleAvatar(
      backgroundColor: experience.iconBackgroundColor,
      radius: 35,
      child: Icon(experience.iconData, color: experience.iconColor, size: 30),
    );
  }

  Widget _experienceCardWidget({required BuildContext context, required Experience experience}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return HoverCardWidget(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // Desktop layout
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _iconWidget(experience: experience),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _titleAndCompanyNameWidget(
                              experience: experience,
                              textTheme: textTheme,
                              colorScheme: colorScheme,
                            ),
                            Text(_periodText(experience), style: textTheme.bodyMedium!),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                // Mobile layout
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _iconWidget(experience: experience),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _titleAndCompanyNameWidget(
                            experience: experience,
                            textTheme: textTheme,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_periodText(experience), style: textTheme.bodyMedium!),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Text(experience.description, style: textTheme.bodyLarge!),
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
              Text('Experiência Profissional', style: Theme.of(context).textTheme.headlineLarge!),
              const SizedBox(height: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: experienceList.map((experience) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _experienceCardWidget(context: context, experience: experience),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
