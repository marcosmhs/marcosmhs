// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/main/main_area_structure.dart';
import 'package:marcosmhs/features/main/routes.dart';
import 'package:marcosmhs/features/site_data/header/site_header_controller.dart';
import 'package:marcosmhs/features/site_data/header/site_header_data.dart';
import 'package:marcosmhs/features/site_data/widgets/site_property_widget.dart';
import 'package:marcosmhs/features/user/user.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';

class SiteHeaderTextForm extends StatefulWidget {
  const SiteHeaderTextForm({super.key});

  @override
  State<SiteHeaderTextForm> createState() => _SiteHeaderTextFormState();
}

class _SiteHeaderTextFormState extends State<SiteHeaderTextForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  var _initializing = true;
  var _saveingData = false;

  var _siteHeader = SiteHeaderText(siteName: Consts.siteName);

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var siteHeaderController = SiteHeaderController();
      TebCustomReturn retorno;
      try {
        retorno = await siteHeaderController.save(mainData: _siteHeader);
        if (retorno.returnType == TebReturnType.sucess) {
          TebCustomMessage.sucess(context, message: 'Dados alterados com sucesso');
          Navigator.of(context).pushReplacementNamed(Routes.mainScreen, arguments: {'user': _user});
        }

        // se houve um erro no login ou no cadastro exibe o erro
        if (retorno.returnType == TebReturnType.error) {
          TebCustomMessage.error(context, message: retorno.message);
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
      SiteHeaderController().getData(siteName: Consts.siteName).then((value) {
        setState(() => _siteHeader = value);
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
                  icon: FaIcon(FontAwesomeIcons.floppyDisk, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _submit(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // name
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [
                SitePropertyType.text,
                SitePropertyType.color,
                SitePropertyType.numeric,
                SitePropertyType.fontWeigh
              ],
              propertyTitle: 'Nome',
              propertyValue: _siteHeader.name,
              propertyFontSize: _siteHeader.nameFontSize,
              propertyFontWeight: _siteHeader.nameFontWeight,
              propertyColor: _siteHeader.nameColor,
              onChangedProperty: (value) => _siteHeader.name = value ?? '',
              onChangedPropertyColor: (selectedColor) => _siteHeader.nameColor = selectedColor!,
              onChangedPropertyFontSize: (value) {
                _siteHeader.nameFontSize = double.tryParse(value ?? '30') ?? 30;
              },
              onFontWeightSelected: (value) {
                if (value != null) {
                  _siteHeader.nameFontWeight = value as FontWeight;
                }
              },
            ),
            const SizedBox(height: 10),
            // name complement
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [
                SitePropertyType.text,
                SitePropertyType.color,
                SitePropertyType.numeric,
                SitePropertyType.fontWeigh,
              ],
              propertyTitle: 'Complemento',
              propertyValue: _siteHeader.nameComplement,
              propertyColor: _siteHeader.nameComplementColor,
              propertyFontSize: _siteHeader.nameComplementFontSize,
              propertyFontWeight: _siteHeader.nameComplementFontWeight,
              onChangedProperty: (value) => _siteHeader.nameComplement = value ?? '',
              onChangedPropertyColor: (selectedColor) => _siteHeader.nameComplementColor = selectedColor!,
              onChangedPropertyFontSize: (value) {
                _siteHeader.nameComplementFontSize = double.tryParse(value ?? '30') ?? 30;
              },
              onFontWeightSelected: (value) {
                if (value != null) {
                  _siteHeader.nameComplementFontWeight = value as FontWeight;
                }
              },
            ),
            const SizedBox(height: 10),
            // email
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Email',
              propertyValue: _siteHeader.email,
              onChangedProperty: (value) => _siteHeader.email = value ?? '',
            ),
            const SizedBox(height: 10),
            // Github
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Github',
              propertyValue: _siteHeader.urlGitGub,
              onChangedProperty: (value) => _siteHeader.urlGitGub = value ?? '',
            ),
            const SizedBox(height: 10),
            // Linkedin
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Linkedin',
              propertyValue: _siteHeader.urlLinkedin,
              onChangedProperty: (value) => _siteHeader.urlLinkedin = value ?? '',
            ),
            const SizedBox(height: 10),
            // Medium
            SiteProperty(
              context: context,
              size: size,
              sitePropertyTypes: const [SitePropertyType.text],
              propertyTitle: 'Medium',
              propertyValue: _siteHeader.urlMedium,
              onChangedProperty: (value) => _siteHeader.urlMedium = value ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
