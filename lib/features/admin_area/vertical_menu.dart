import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/admin_area/site_publisher.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:marcosmhs/features/admin_area/user/user_controller.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
          onTap: () =>
              Navigator.of(context).pushNamed(Routes.userForm, arguments: {'user': widget.user}),
          child: CircleAvatar(
            child: FaIcon(
              FontAwesomeIcons.user,
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          ),
        ),
        accountName: TebText(widget.user.name, fontColor: Theme.of(context).colorScheme.surface),
        accountEmail: TebText(widget.user.email, fontColor: Theme.of(context).colorScheme.surface),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.palette, color: Theme.of(context).colorScheme.primary),
        title: TebText('Configuração Geral', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteMainData,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.gear, color: Theme.of(context).colorScheme.primary),
        title: TebText('Cabeçalho (header)', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteHeaderTextForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.book, color: Theme.of(context).colorScheme.primary),
        title: TebText('Intodução', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteIntroTextForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.person, color: Theme.of(context).colorScheme.primary),
        title: TebText('Sobre Mim', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteAboutMeTextForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.person, color: Theme.of(context).colorScheme.primary),
        title: TebText('Sobre Mim - Tecnologias', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.siteAboutMeTechnologiesForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.pager, color: Theme.of(context).colorScheme.primary),
        title: TebText('Experiência', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.experienceForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.penFancy, color: Theme.of(context).colorScheme.primary),
        title: TebText('Artigos', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.articleForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      ListTile(
        leading:
            FaIcon(FontAwesomeIcons.diagramProject, color: Theme.of(context).colorScheme.primary),
        title: TebText('Projetos', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.projectForm,
          arguments: {'user': widget.user, 'mobile': widget.mobile},
        ),
      ),
      const Spacer(),
      ListenableBuilder(
        listenable: SitePublisher.instance,
        builder: (context, _) {
          final publisher = SitePublisher.instance;
          return ListTile(
            enabled: !publisher.busy,
            leading: publisher.busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : FaIcon(
                    FontAwesomeIcons.cloudArrowUp,
                    color: publisher.state == SitePublishState.error
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
            title: TebText('Publicar site agora', fontColor: Theme.of(context).colorScheme.primary),
            subtitle: TebText(publisher.statusText, fontSize: 12),
            onTap: publisher.publishNow,
          );
        },
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.sitemap, color: Theme.of(context).colorScheme.primary),
        title: TebText('Voltar para o Site', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () => launchUrlString('/', webOnlyWindowName: '_self'),
      ),
      ListTile(
        leading: FaIcon(FontAwesomeIcons.doorClosed, color: Theme.of(context).colorScheme.primary),
        title: TebText('Sair', fontColor: Theme.of(context).colorScheme.primary),
        onTap: () {
          UserController().logoff();
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
        },
      ),
      const SizedBox(height: 10),
      TebText(
        "v${_info.version}.${_info.buildNumber}",
        fontColor: Theme.of(context).colorScheme.primary,
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
    return widget.mobile
        ? Drawer(child: menuItens())
        : SizedBox(width: widget.size.width * 0.2, child: menuItens());
  }
}
