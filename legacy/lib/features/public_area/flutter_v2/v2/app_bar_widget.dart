import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/app_theme.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  static const _adminMenuValue = 'Admin';

  final Map<String, GlobalKey> sectionKeys;
  final Function(GlobalKey key) onNavigate;
  final String title;
  final String version;
  final Color? backgroundColor;
  final Color? titleFontColor;

  const AppBarWidget({
    super.key,
    required this.sectionKeys,
    required this.onNavigate,
    required this.title,
    this.backgroundColor,
    this.titleFontColor,
    required this.version,
  });

  Widget _titleWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TebText(
          title,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontColor: titleFontColor,
          letterSpacing: 2,
        ),
        TebText(
          version,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontColor: titleFontColor,
          letterSpacing: 2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return AppBar(
            backgroundColor: backgroundColor ?? Colors.white,
            elevation: 4.0,
            title: _titleWidget(),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (value) {
                  final key = sectionKeys[value];
                  if (key != null) {
                    onNavigate(key);
                  } else {
                    Navigator.of(context).pushNamed(Routes.loginScreen);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    ...sectionKeys.keys.map((String choice) {
                      return PopupMenuItem<String>(value: choice, child: Text(choice));
                    }),
                    const PopupMenuItem<String>(value: _adminMenuValue, child: Text('Admin')),
                  ];
                },
              ),
            ],
          );
        } else {
          // Layout para Desktop
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 4.0,
            toolbarHeight: 64,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Row(
                children: [
                  _titleWidget(),
                  const Spacer(),
                  ...sectionKeys.keys.map((key) {
                    return TextButton(
                      onPressed: () => onNavigate(sectionKeys[key]!),
                      child: TebText(
                        key,
                        fontColor: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  }),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(Routes.loginScreen),
                    child: Icon(FontAwesomeIcons.user),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
