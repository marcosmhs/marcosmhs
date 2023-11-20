// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/main_area_structure.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_controller.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/admin_area/widgets/site_property_widget.dart';
import 'package:teb_package/teb_package.dart';

class SiteAboutMeTechnologiestForm extends StatefulWidget {
  const SiteAboutMeTechnologiestForm({super.key});

  @override
  State<SiteAboutMeTechnologiestForm> createState() => _SiteAboutMeTechnologiestFormState();
}

class _SiteAboutMeTechnologiestFormState extends State<SiteAboutMeTechnologiestForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  var _initializing = true;
  var _saveingData = false;
  final List<AboutMeTechnology> _siteAboutMeTechnologyList = [];

  void _addAboutMeTechnologyDataList({required AboutMeTechnologyType aboutMeTechnologyType}) {
    List<AboutMeTechnology> aboutMeTechnologyListBkp = [];
    aboutMeTechnologyListBkp.addAll(_siteAboutMeTechnologyList);

    aboutMeTechnologyListBkp.add(AboutMeTechnology(siteName: Consts.siteName, type: aboutMeTechnologyType));
    _siteAboutMeTechnologyList.clear();
    _siteAboutMeTechnologyList.addAll(aboutMeTechnologyListBkp);
    setState(() {});
  }

  void _setTechnologyToRemove({required AboutMeTechnology aboutMeTechnology}) {
    TebCustomDialog(context: context).confirmationDialog(message: 'Excluir?').then((value) {
      if (value == true) {
        if (aboutMeTechnology.id.isEmpty) {
          setState(() => _siteAboutMeTechnologyList.remove(aboutMeTechnology));
        } else {
          setState(() => aboutMeTechnology.status == AboutMeItemStatus.delete);
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
        retorno = await siteAboutMeController.saveAboutTechnologyList(aboutMeTechnologyList: _siteAboutMeTechnologyList);

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

      SiteAboutMeController().getAboutMeTechnologyListData(siteName: Consts.siteName).then((introTechList) {
        if (introTechList.isEmpty) introTechList.add(AboutMeTechnology(siteName: Consts.siteName));
        setState(() => _siteAboutMeTechnologyList.addAll(introTechList));
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
            // technologies column
            Row(
              children: [
                const TebText('Tecnologias Conhecidas - Desenvolvimento', textSize: 20),
                const Spacer(),
                TebButton(
                  label: 'Adicionar',
                  icon: FaIcon(FontAwesomeIcons.plus, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _addAboutMeTechnologyDataList(aboutMeTechnologyType: AboutMeTechnologyType.development),
                ),
              ],
            ),
            technologyList(context: context, size: size, aboutMeTechnologyType: AboutMeTechnologyType.development),
            const SizedBox(height: 10),
            // technologies column
            Row(
              children: [
                const TebText('Tecnologias Conhecidas - Data Science', textSize: 20),
                const Spacer(),
                TebButton(
                  label: 'Adicionar',
                  icon: FaIcon(FontAwesomeIcons.plus, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _addAboutMeTechnologyDataList(aboutMeTechnologyType: AboutMeTechnologyType.dataScience),
                ),
              ],
            ),
            technologyList(context: context, size: size, aboutMeTechnologyType: AboutMeTechnologyType.dataScience),
          ],
        ),
      ),
    );
  }

  SizedBox technologyList({
    required BuildContext context,
    required Size size,
    required AboutMeTechnologyType aboutMeTechnologyType,
  }) {
    var localSiteAboutMeTechnologyList = _siteAboutMeTechnologyList.where((t) => t.type == aboutMeTechnologyType).toList();
    return SizedBox(
      height: size.height * 0.8,
      width: size.width * 0.78,
      child: ListView.builder(
        itemCount: localSiteAboutMeTechnologyList.length,
        itemBuilder: (itemBuildercontext, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SiteProperty(
                context: context,
                size: size,
                sitePropertyTypes: const [SitePropertyType.device, SitePropertyType.text],
                propertyTitle: '',
                propertyValue: localSiteAboutMeTechnologyList[index].technologyName,
                propertyDesktop: localSiteAboutMeTechnologyList[index].desktop,
                propertyMobile: localSiteAboutMeTechnologyList[index].mobile,
                propertyMemoInput: false,
                onChangedProperty: (value) => localSiteAboutMeTechnologyList[index].technologyName = value!,
                onDeviceMobileSelected: (selected) => setState(() => localSiteAboutMeTechnologyList[index].mobile = selected!),
                onDeviceDesktopSelected: (selected) => setState(() => localSiteAboutMeTechnologyList[index].desktop = selected!),
                onValidateProperty: (value) {
                  final finalValue = value ?? '';
                  if (finalValue.trim().isEmpty) return 'Informe o nome';
                  return null;
                },
                showActionButton: true,
                actionButtonLabel: 'Remover',
                actionButtonIcon: FaIcon(FontAwesomeIcons.trashCan, color: Theme.of(context).colorScheme.background),
                actionButtonPressed: () => _setTechnologyToRemove(aboutMeTechnology: localSiteAboutMeTechnologyList[index]),
              ),
            ],
          );
        },
      ),
    );
  }
}
