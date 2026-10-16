// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/site_publisher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/main_area_structure.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text.dart';
import 'package:marcosmhs/features/admin_area/intro_text/site_intro_text_controller.dart';
import 'package:marcosmhs/features/admin_area/widgets/site_property_widget.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:teb_package/teb_package.dart';

class SiteIntroTextForm extends StatefulWidget {
  const SiteIntroTextForm({super.key});

  @override
  State<SiteIntroTextForm> createState() => _SiteIntroTextFormState();
}

class _SiteIntroTextFormState extends State<SiteIntroTextForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  var _initializing = true;
  var _saveingData = false;
  final List<IntroTextData> _introTextDataList = [];

  void _addIntroTextDataList() {
    List<IntroTextData> introTextDataListBkp = [];
    introTextDataListBkp.addAll(_introTextDataList);

    introTextDataListBkp.add(IntroTextData(siteName: Consts.siteName));
    _introTextDataList.clear();
    _introTextDataList.addAll(introTextDataListBkp);
    setState(() {});
  }

  void _setItemToRemove({required IntroTextData introTextData}) {
    TebDialog(context: context).confirmationDialog(message: 'Excluir este texto?').then((value) {
      if (value == true) {
        if (introTextData.id.isEmpty) {
          setState(() => _introTextDataList.remove(introTextData));
        } else {
          setState(() => introTextData.status == IntroTextDataStatus.delete);
        }
      }
    });
  }

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var siteIntroTextController = SiteIntroTextController();
      TebReturn retorno;
      try {
        retorno = await siteIntroTextController.save(introTextDataList: _introTextDataList);
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
      _initializing = false;
      SiteIntroTextController().getData(siteName: Consts.siteName).then((introTextList) {
        if (introTextList.isEmpty) introTextList.add(IntroTextData(siteName: Consts.siteName));
        setState(() => _introTextDataList.addAll(introTextList));
      });
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
            // button options
            TebButtonsLine(
              mainAxisAlignment: MainAxisAlignment.end,
              padding: const EdgeInsets.symmetric(vertical: 10),
              buttons: [
                TebButton(
                  label: 'Adicionar linha',
                  onPressed: () => _addIntroTextDataList(),
                ),
                const Spacer(),
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
            // intro text list
            SizedBox(
              height: size.height * 0.8,
              width: size.width * 0.78,
              child: ListView.builder(
                itemCount: _introTextDataList.length,
                itemBuilder: (itemBuildercontext, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_introTextDataList[index].status != IntroTextDataStatus.delete)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TebButton(
                            label: 'Remover',
                            icon: FaIcon(FontAwesomeIcons.trashCan,
                                color: Theme.of(context).colorScheme.surface),
                            onPressed: () =>
                                _setItemToRemove(introTextData: _introTextDataList[index]),
                          ),
                        ),
                      if (_introTextDataList[index].status == IntroTextDataStatus.delete)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TebButton(
                            label: 'OK',
                            icon: FaIcon(FontAwesomeIcons.trashCan,
                                color: Theme.of(context).colorScheme.surface),
                            onPressed: () =>
                                _setItemToRemove(introTextData: _introTextDataList[index]),
                          ),
                        ),
                      SiteProperty(
                        context: context,
                        size: size,
                        sitePropertyTypes: const [
                          SitePropertyType.fontWeigh,
                          SitePropertyType.numeric,
                          SitePropertyType.text,
                        ],
                        propertyTitle: '',
                        propertyValue: _introTextDataList[index].introText,
                        propertyFontSize: _introTextDataList[index].fontSize,
                        propertyFontWeight: _introTextDataList[index].fontWeight,
                        propertyMemoInput: true,
                        onChangedProperty: (value) => _introTextDataList[index].introText = value!,
                        onFontWeightSelected: (value) =>
                            _introTextDataList[index].fontWeight = value as FontWeight,
                        onChangedPropertyFontSize: (value) => _introTextDataList[index].fontSize =
                            value == null
                                ? Consts.stdIntroTextFontSize
                                : (double.tryParse(value) ?? Consts.stdIntroTextFontSize),
                        onChangedPropertyColor: (selectedColor) =>
                            _introTextDataList[index].fontColor = selectedColor!,
                        onDeviceMobileSelected: (selected) =>
                            setState(() => _introTextDataList[index].mobile = selected!),
                        onDeviceDesktopSelected: (selected) =>
                            setState(() => _introTextDataList[index].desktop = selected!),
                        onValidateProperty: (value) {
                          final finalValue = value ?? '';
                          if (finalValue.trim().isEmpty) return 'O texto deve ser informado';
                          return null;
                        },
                        onValidatePropertyFontSize: (value) {
                          final finalValue = value ?? '';
                          if (finalValue.trim().isEmpty) {
                            return 'O tamanho do texto deve ser informado';
                          }
                          if (double.tryParse(value ?? '') == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
