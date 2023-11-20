import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:marcosmhs/features/admin_area/user/user_controller.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class VerticalMenu extends StatefulWidget {
  final User user;
  final Size size;
  final bool mobile;
  const VerticalMenu({super.key, required this.mobile, required this.user, required this.size});

  @override
  State<VerticalMenu> createState() => _VerticalMenuState();
}

class _VerticalMenuState extends State<VerticalMenu> {
  var _info = TebUtil.packageInfo;
  var _initializing = true;

  Widget menuItens() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      UserAccountsDrawerHeader(
        currentAccountPicture: InkWell(
          onTap: () => Navigator.of(context).pushNamed(Routes.userForm, arguments: {'user': widget.user}),
          child: CircleAvatar(
            child: FaIcon(
              FontAwesomeIcons.user,
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          ),
        ),
        accountName: TebText(widget.user.name, textColor: Theme.of(context).colorScheme.background),
        accountEmail: TebText(widget.user.email, textColor: Theme.of(context).colorScheme.background),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.palette, color: Theme.of(context).colorScheme.primary),
        title: TebText('Configuração Geral', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteMainData,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.gear, color: Theme.of(context).colorScheme.primary),
        title: TebText('Cabeçalho (header)', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteHeaderTextForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.book, color: Theme.of(context).colorScheme.primary),
        title: TebText('Intodução', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteIntroTextForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.person, color: Theme.of(context).colorScheme.primary),
        title: TebText('Sobre Mim', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteAboutMeTextForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.person, color: Theme.of(context).colorScheme.primary),
        title: TebText('Sobre Mim - Tecnologias', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteAboutMeTechnologiesForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.pager, color: Theme.of(context).colorScheme.primary),
        title: TebText('Experiência', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.experienceForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.penFancy, color: Theme.of(context).colorScheme.primary),
        title: TebText('Artigos', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.articleForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.diagramProject, color: Theme.of(context).colorScheme.primary),
        title: TebText('Projetos', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.projectForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      const Spacer(),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.sitemap, color: Theme.of(context).colorScheme.primary),
        title: TebText('Voltar para o Site', textColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).popAndPushNamed(Routes.landingScreen),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.doorClosed, color: Theme.of(context).colorScheme.primary),
        title: TebText('Sair', textColor: Theme.of(context).colorScheme.primary),
        onTap: () {
          UserController().logoff();
          Navigator.of(context).popAndPushNamed(Routes.landingScreen);
        },
      ),
      const SizedBox(height: 10),
      TebText(
        "v${_info.version}.${_info.buildNumber}",
        textColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.only(bottom: 10),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      TebUtil.version.then((info) => setState(() => _info = info));
      _initializing = false;
    }
    return widget.mobile ? Drawer(child: menuItens()) : SizedBox(width: widget.size.width * 0.2, child: menuItens());
  }
}
