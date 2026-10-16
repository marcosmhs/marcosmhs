import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/public_area/url_manager.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class Contact {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String actionText;
  final String url;

  const Contact({
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.url,
  });
}

class ContactAreaWidget extends StatelessWidget {
  const ContactAreaWidget({super.key});

  static final List<Contact> _contactsList = [
    Contact(
      icon: FontAwesomeIcons.solidEnvelope,
      iconBackgroundColor: const Color(0xFF2563EB),
      title: 'Email',
      subtitle: 'marcosmhs@live.com',
      actionText: 'Enviar mensagem',
      url: 'mailto:marcosmhs@live.com',
    ),
    Contact(
      icon: FontAwesomeIcons.linkedin,
      iconBackgroundColor: const Color(0xFF1D4ED8),
      title: 'LinkedIn',
      subtitle: 'linkedin.com/in/marcosmhs',
      actionText: 'Conectar',
      url: 'https://linkedin.com/in/marcosmhs',
    ),
    Contact(
      icon: FontAwesomeIcons.github,
      iconBackgroundColor: const Color(0xFF1F2937),
      title: 'GitHub',
      subtitle: 'github.com/marcosmhs',
      actionText: 'Ver repositórios',
      url: 'https://github.com/marcosmhs',
    ),
    Contact(
      icon: FontAwesomeIcons.medium,
      iconBackgroundColor: const Color(0xFF1F2937),
      title: 'Medium',
      subtitle: '@marcosmhs',
      actionText: 'Ler artigos',
      url: 'https://medium.com/@marcosmhs/',
    ),
  ];

  Widget _infoWidget(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        TebText(text, fontColor: Colors.grey[600]),
      ],
    );
  }

  Widget _contactCardWidget({required BuildContext context, required Contact contact}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: const Color(0xFFF0F9FF),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => UrlManager.launchUrl(url: contact.url),
        hoverColor: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(32.0), // p-8
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo com o ícone
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: contact.iconBackgroundColor,
                ),
                child: Center(child: Icon(contact.icon, color: Colors.white, size: 28)),
              ),
              const SizedBox(height: 16),
              Text(contact.title, style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(contact.subtitle, style: textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                contact.actionText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TebText('Vamos conversar?', style: textTheme.headlineLarge!),
              const SizedBox(height: 64),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  if (constraints.maxWidth >= 768) {
                    // md
                    crossAxisCount = 3;
                  } else {
                    crossAxisCount = 1;
                  }

                  const double gap = 32.0;
                  final double itemWidth =
                      (constraints.maxWidth - (gap * (crossAxisCount - 1))) / crossAxisCount;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: _contactsList.map((contact) {
                      return SizedBox(
                        width: itemWidth,
                        child: _contactCardWidget(context: context, contact: contact),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 48),
              TebText(
                'Interessado em colaborar ou discutir oportunidades? Estou sempre aberto a conversas sobre dados, tecnologia e inovação.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _infoWidget(context, FontAwesomeIcons.locationDot, 'Curitiba, Brasil'),
                    _infoWidget(context, FontAwesomeIcons.solidClock, 'Disponível para projetos'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
