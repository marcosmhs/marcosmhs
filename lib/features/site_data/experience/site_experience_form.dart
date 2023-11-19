// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/main/main_area_structure.dart';
import 'package:marcosmhs/features/main/routes.dart';
import 'package:marcosmhs/features/site_data/experience/site_experience_controller.dart';
import 'package:marcosmhs/features/site_data/experience/site_experience_data.dart';
import 'package:marcosmhs/features/user/user.dart';
import 'package:teb_package/teb_package.dart';

class ExperienceForm extends StatefulWidget {
  const ExperienceForm({super.key});

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  var _initializing = true;
  var _saveingData = false;
  final List<Experience> _experienceList = [];

  void _addExperienceList() {
    List<Experience> experienceListBkp = [];
    experienceListBkp.addAll(_experienceList);

    experienceListBkp.add(Experience(siteName: Consts.siteName));
    _experienceList.clear();
    _experienceList.addAll(experienceListBkp);
    setState(() {});
  }

  void _setExperienceToRemove({required Experience experience}) {
    TebCustomDialog(context: context).confirmationDialog(message: 'Excluir esta experiência?').then((value) {
      if (value == true) {
        if (experience.id.isEmpty) {
          setState(() => _experienceList.remove(experience));
        } else {
          setState(() => experience.setToRemove());
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
      var experienceController = ExperienceController();
      TebCustomReturn retorno;
      try {
        retorno = await experienceController.save(experienceList: _experienceList);

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

  void _selectFaIcon({required Experience experience}) {
    TebFaIconPicker.showFaIconPickerDialog(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      specialColor: Theme.of(context).colorScheme.inversePrimary,
    ).then((value) {
      if (value != null) setState(() => experience.iconData = value);
    });
  }

  void _iconBackgroundColor({required Experience experience}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma cor'),
          content: MaterialPicker(
            pickerColor: experience.iconBackgroundColor,
            onColorChanged: (selectecColor) {
              setState(() => experience.iconBackgroundColor = selectecColor);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _iconColor({required Experience experience}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione uma cor'),
          content: MaterialPicker(
            pickerColor: experience.iconColor,
            onColorChanged: (selectecColor) {
              setState(() => experience.iconColor = selectecColor);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  String? _textEditValidator(String? value, String errorMessage) {
    var finalValue = value ?? '';
    if (finalValue.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  Widget _experienceItem({required Experience experience}) {
    final size = MediaQuery.of(context).size;

    final TextEditingController orderController = TextEditingController(text: experience.order.toString());
    final TextEditingController titleController = TextEditingController(text: experience.title);
    final TextEditingController companyController = TextEditingController(text: experience.company);
    final TextEditingController descriptionController = TextEditingController(text: experience.description);
    final TextEditingController durationStartController = TextEditingController(text: experience.durationStart);
    final TextEditingController durationEndController = TextEditingController(text: experience.durationEnd);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // icon
          SizedBox(
            width: size.width * 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: experience.iconBackgroundColor,
                  radius: 30,
                  child: Center(
                    child: Icon(
                      experience.iconData,
                      color: experience.iconColor,
                      size: 30,
                    ),
                  ),
                ),
                TebButton(
                  label: 'Ícone',
                  icon: FaIcon(FontAwesomeIcons.icons, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _selectFaIcon(experience: experience),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                TebButton(
                  label: 'Cor de ícone',
                  icon: FaIcon(FontAwesomeIcons.paintRoller, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _iconColor(experience: experience),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                TebButton(
                  label: 'Cor de fundo',
                  icon: FaIcon(FontAwesomeIcons.paintRoller, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _iconBackgroundColor(experience: experience),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ],
            ),
          ),
          // text info
          SizedBox(
            width: size.width * 0.55,
            child: Column(
              children: [
                Row(
                  children: [
                    TebTextEdit(
                      width: size.width * 0.05,
                      labelText: 'Ordem',
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      onSave: (value) => experience.order = int.tryParse(value ?? '') ?? 0,
                      onChanged: (value) => experience.order = int.tryParse(value ?? '') ?? 0,
                      validator: (value) => _textEditValidator(value, 'Informe a ordem'),
                    ),
                    const Spacer(),
                    TebTextEdit(
                      width: size.width * 0.48,
                      labelText: 'Cargo',
                      controller: titleController,
                      onSave: (value) => experience.title = value ?? '',
                      onChanged: (value) => experience.title = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o cargo'),
                    ),
                  ],
                ),
                TebTextEdit(
                  labelText: 'Empresa',
                  controller: companyController,
                  onSave: (value) => experience.company = value ?? '',
                  onChanged: (value) => experience.company = value ?? '',
                  validator: (value) => _textEditValidator(value, 'Informe a empresa'),
                ),
                TebTextEdit(
                  labelText: 'Descrição',
                  controller: descriptionController,
                  onSave: (value) => experience.description = value ?? '',
                  onChanged: (value) => experience.description = value ?? '',
                  validator: (value) => _textEditValidator(value, 'Informe a descrição'),
                ),
                Row(
                  children: [
                    TebTextEdit(
                      width: 150,
                      labelText: 'Início',
                      controller: durationStartController,
                      onSave: (value) => experience.durationStart = value ?? '',
                      onChanged: (value) => experience.durationStart = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o início'),
                    ),
                    const TebText('até', padding: EdgeInsets.symmetric(horizontal: 10)),
                    TebTextEdit(
                      width: 150,
                      labelText: 'Término',
                      onSave: (value) => experience.durationEnd = value ?? '',
                      onChanged: (value) => experience.durationEnd = value ?? '',
                      controller: durationEndController,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // remove option
          SizedBox(
            width: size.width * 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TebButton(
                  label: 'Remover',
                  icon: FaIcon(FontAwesomeIcons.trashCan, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _setExperienceToRemove(experience: experience),
                  enabled: experience.status != ExperienceStatus.delete,
                ),
                if (experience.status == ExperienceStatus.delete)
                  const TebText(
                    'Excluído',
                    padding: EdgeInsets.all(8),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      ExperienceController().getData(siteName: Consts.siteName).then((experienceList) {
        _experienceList.clear();
        if (experienceList.isEmpty) experienceList.add(Experience(siteName: Consts.siteName));
        setState(() => _experienceList.addAll(experienceList));
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
                const TebText('Experiência', textSize: 20),
                const Spacer(),
                TebButton(
                  label: 'Adicionar nova experiência',
                  icon: FaIcon(FontAwesomeIcons.plus, color: Theme.of(context).colorScheme.background),
                  onPressed: () => _addExperienceList(),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.8,
              width: size.width * 0.78,
              child: ListView.builder(
                itemCount: _experienceList.length,
                itemBuilder: (itemBuildercontext, index) {
                  return _experienceItem(experience: _experienceList[index]);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
