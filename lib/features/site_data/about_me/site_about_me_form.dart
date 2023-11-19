// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_network/image_network.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/main/main_area_structure.dart';
import 'package:marcosmhs/features/main/routes.dart';
import 'package:marcosmhs/features/site_data/about_me/site_about_me_controller.dart';
import 'package:marcosmhs/features/site_data/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/site_data/widgets/site_property_widget.dart';
import 'package:marcosmhs/features/user/user.dart';
import 'package:teb_package/teb_package.dart';
import 'package:teb_package/visual_elements/teb_file_picker.dart';

class SiteAboutMeTextForm extends StatefulWidget {
  const SiteAboutMeTextForm({super.key});

  @override
  State<SiteAboutMeTextForm> createState() => _SiteAboutMeTextFormState();
}

class _SiteAboutMeTextFormState extends State<SiteAboutMeTextForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  var _initializing = true;
  var _saveingData = false;
  final List<AboutMeText> _siteAboutMeTextList = [];

  var _aboutMeData = AboutMeData(siteName: Consts.siteName);

  void _addAboutMeTextDataList() {
    List<AboutMeText> siteAboutMeTextListBkp = [];
    siteAboutMeTextListBkp.addAll(_siteAboutMeTextList);

    siteAboutMeTextListBkp.add(AboutMeText(siteName: Consts.siteName));
    _siteAboutMeTextList.clear();
    _siteAboutMeTextList.addAll(siteAboutMeTextListBkp);
    setState(() {});
  }

  void _setIntroTextToRemove({required AboutMeText aboutMeText}) {
    TebCustomDialog(context: context).confirmationDialog(message: 'Excluir este parágrafo?').then((value) {
      if (value == true) {
        if (aboutMeText.id.isEmpty) {
          setState(() => _siteAboutMeTextList.remove(aboutMeText));
        } else {
          setState(() => aboutMeText.status == AboutMeItemStatus.delete);
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
      var siteAboutMeController = SiteAboutMeController();
      TebCustomReturn retorno;
      try {
        retorno = await siteAboutMeController.saveAboutMeData(aboutMeData: _aboutMeData);

        if (retorno.returnType == TebReturnType.sucess) {
          retorno = await siteAboutMeController.saveAboutMeTextList(aboutMeTextList: _siteAboutMeTextList);
        }

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
      _initializing = false;
      SiteAboutMeController().getAboutMeData(siteName: Consts.siteName).then((aboutMeData) {
        setState(() => _aboutMeData = aboutMeData);
      });

      SiteAboutMeController().getAboutMeTextListData(siteName: Consts.siteName).then((introTextList) {
        if (introTextList.isEmpty) introTextList.add(AboutMeText(siteName: Consts.siteName));
        setState(() => _siteAboutMeTextList.addAll(introTextList));
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // button options
            TebButtonsLine(
              mainAxisAlignment: MainAxisAlignment.end,
              padding: const EdgeInsets.symmetric(vertical: 10),
              buttons: [
                const Spacer(),
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
            // intro text title
            Row(
              children: [
                const TebText('Parágrafos iniciais', textSize: 20),
                const Spacer(),
                TebButton(
                  label: 'Adicionar novo parágrafo',
                  icon: FaIcon(FontAwesomeIcons.plus, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _addAboutMeTextDataList(),
                ),
              ],
            ),
            // intro text list
            SizedBox(
              height: size.height * 0.8,
              width: size.width * 0.78,
              child: ListView.builder(
                itemCount: _siteAboutMeTextList.length,
                itemBuilder: (itemBuildercontext, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_siteAboutMeTextList[index].status != AboutMeItemStatus.delete)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TebButton(
                            label: 'Remover',
                            icon: FaIcon(FontAwesomeIcons.trashCan, color: Theme.of(context).colorScheme.background),
                            onPressed: () => _setIntroTextToRemove(aboutMeText: _siteAboutMeTextList[index]),
                          ),
                        ),
                      SiteProperty(
                        context: context,
                        size: size,
                        sitePropertyTypes: const [
                          SitePropertyType.color,
                          SitePropertyType.device,
                          SitePropertyType.fontWeigh,
                          SitePropertyType.numeric,
                          SitePropertyType.text,
                        ],
                        propertyTitle: '',
                        propertyValue: _siteAboutMeTextList[index].aboutMeText,
                        propertyFontSize: _siteAboutMeTextList[index].fontSize,
                        propertyColor: _siteAboutMeTextList[index].fontColor,
                        propertyFontWeight: _siteAboutMeTextList[index].fontWeight,
                        propertyDesktop: _siteAboutMeTextList[index].desktop,
                        propertyMobile: _siteAboutMeTextList[index].mobile,
                        propertyMemoInput: true,
                        onChangedProperty: (value) => _siteAboutMeTextList[index].aboutMeText = value!,
                        onFontWeightSelected: (value) => _siteAboutMeTextList[index].fontWeight = value as FontWeight,
                        onChangedPropertyFontSize: (value) => _siteAboutMeTextList[index].fontSize =
                            value == null ? Consts.stdIntroTextFontSize : (double.tryParse(value) ?? Consts.stdIntroTextFontSize),
                        onChangedPropertyColor: (selectedColor) => _siteAboutMeTextList[index].fontColor = selectedColor!,
                        onDeviceMobileSelected: (selected) => setState(() => _siteAboutMeTextList[index].mobile = selected!),
                        onDeviceDesktopSelected: (selected) => setState(() => _siteAboutMeTextList[index].desktop = selected!),
                        onValidateProperty: (value) {
                          final finalValue = value ?? '';
                          if (finalValue.trim().isEmpty) return 'O texto deve ser informado';
                          return null;
                        },
                        onValidatePropertyFontSize: (value) {
                          final finalValue = value ?? '';
                          if (finalValue.trim().isEmpty) return 'O tamanho do texto deve ser informado';
                          if (double.tryParse(value ?? '') == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Image selection
            TebButtonsLine(
              mainAxisAlignment: MainAxisAlignment.start,
              padding: const EdgeInsets.symmetric(vertical: 10),
              buttons: [
                TebFilePickerWeb(
                  buttonLabel: 'Selecionar foto',
                  icon: FaIcon(FontAwesomeIcons.image, color: Theme.of(context).colorScheme.background),
                  onPicked: (image) => setState(() => _aboutMeData.photo = image),
                ),
              ],
            ),
            // image
            if (_aboutMeData.profilePhotoUrl.isNotEmpty && _aboutMeData.photo == null)
              SizedBox(
                width: size.width * 0.6,
                height: size.height * 0.5,
                child: ImageNetwork(
                  image: _aboutMeData.profilePhotoUrl,
                  width: size.width * 0.5,
                  height: size.height * 0.5,
                  fitWeb: BoxFitWeb.scaleDown,
                ),
              ),
            InkWell(
              child: Text(_aboutMeData.profilePhotoUrl),
              onTap: () => TebUrlManager.launchUrl(url: _aboutMeData.profilePhotoUrl),
            ),
            if (_aboutMeData.photo != null)
              SizedBox(
                width: size.width * 0.6,
                height: size.height * 0.5,
                child: Image(image: _aboutMeData.photo!, width: size.width * 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
