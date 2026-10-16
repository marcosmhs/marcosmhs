// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/site_publisher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/main_area_structure.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data_controller.dart';
import 'package:marcosmhs/features/admin_area/widgets/site_property_widget.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:teb_package/control_widgets/teb_buttons_line.dart';
import 'package:teb_package/messaging/teb_message.dart';
import 'package:teb_package/util/teb_return.dart';

class SiteMainDataForm extends StatefulWidget {
  const SiteMainDataForm({super.key});

  @override
  State<SiteMainDataForm> createState() => _SiteMainDataFormState();
}

class _SiteMainDataFormState extends State<SiteMainDataForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  //var _mobile = false;
  var _initializing = true;
  var _saveingData = false;

  var _siteMainData = SiteMainData(siteName: Consts.siteName);

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var siteMainDataController = SiteMainDataController();
      TebReturn retorno;
      try {
        retorno = await siteMainDataController.save(mainData: _siteMainData);
        if (retorno.returnType == TebReturnType.sucess) {
          TebMessage.success(context, message: 'Dados alterados com sucesso');
          SitePublisher.instance.requestPublish();
          Navigator.of(context).pushReplacementNamed(Routes.mainScreen, arguments: {'user': _user});
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebMessage.error(context, message: retorno.message);
        }
      } finally {
        _saveingData = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      _siteMainData = arguments['siteMainData'] ?? SiteMainData(siteName: Consts.siteName);
      //_mobile = arguments['mobile'] ?? false;
      SiteMainDataController().getData(siteName: Consts.siteName).then((value) {
        setState(() => _siteMainData = value);
      });
      _initializing = false;
    }
    final Size size = MediaQuery.of(context).size;

    return MainAreaStructure(
      mobile: size.width < 1000,
      user: _user,
      size: size,
      widget: Form(
        key: _formKey,
        child: Column(
          children: [
            // butons
            TebButtonsLine(
              mainAxisAlignment: MainAxisAlignment.end,
              padding: const EdgeInsets.symmetric(vertical: 10),
              buttons: [
                TebButton(
                  label: 'Cancelar',
                  icon: const FaIcon(FontAwesomeIcons.ban),
                  buttonType: TebButtonType.outlinedButton,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TebButton(
                  label: 'Salvar',
                  icon: FaIcon(FontAwesomeIcons.floppyDisk,
                      color: Theme.of(context).colorScheme.surface),
                  onPressed: () => _submit(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // About me
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Título: Sobre mim (deixe em branco para remover esta sessão)',
              propertyValue: _siteMainData.aboutMeAreaTitle,
              onChangedProperty: (value) => _siteMainData.aboutMeAreaTitle = value ?? '',
            ),
            // Experience
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Título: Experiência (deixe em branco para remover esta sessão)',
              propertyValue: _siteMainData.experienceAreaTitle,
              onChangedProperty: (value) => _siteMainData.experienceAreaTitle = value ?? '',
            ),
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Título: Artigos (deixe em branco para remover esta sessão)',
              propertyValue: _siteMainData.articleAreaTitle,
              onChangedProperty: (value) => _siteMainData.articleAreaTitle = value ?? '',
            ),
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Título: Projetos Recentes (deixe em branco para remover esta sessão)',
              propertyValue: _siteMainData.projectsAreaTitle,
              onChangedProperty: (value) => _siteMainData.projectsAreaTitle = value ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
