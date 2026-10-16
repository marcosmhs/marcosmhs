// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/site_publisher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/consts.dart';
import 'package:marcosmhs/features/admin_area/content/content_controller.dart';
import 'package:marcosmhs/features/admin_area/main_area_structure.dart';
import 'package:marcosmhs/features/public_area/routes.dart';
import 'package:marcosmhs/features/admin_area/projects/project_controller.dart';
import 'package:marcosmhs/features/admin_area/projects/project_data.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:teb_package/teb_package.dart';

class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  var _user = User();
  var _initializing = true;
  var _saveingData = false;
  final List<Project> _projectList = [];
  Set<String> _idsWithContent = {};

  Future<void> _loadContentStatus() async {
    final ids = await ContentController(ContentKind.project).idsWithContent();
    if (mounted) setState(() => _idsWithContent = ids);
  }

  /// Abre o editor do texto da página do projeto (/projetos/{slug}/).
  Future<void> _openContentEditor(Project project) async {
    final github = project.urlGithub.isNotEmpty
        ? project.urlGithub
        : (project.url.contains('github.com') ? project.url : '');
    await Navigator.of(context).pushNamed(
      Routes.contentForm,
      arguments: {
        'user': _user,
        'item': ContentItem(
          kind: ContentKind.project,
          id: project.id,
          title: project.title,
          originUrl: github,
          slug: project.slug,
          summary: project.summary,
        ),
      },
    );
    // o editor/importação podem ter preenchido slug e resumo
    final projects = await ProjectsController().getData(siteName: Consts.siteName);
    if (!mounted) return;
    setState(() {
      _projectList
        ..clear()
        ..addAll(projects);
    });
    _loadContentStatus();
  }

  void _addProjectList() {
    List<Project> projectListBkp = [];
    projectListBkp.addAll(_projectList);

    projectListBkp.add(Project(siteName: Consts.siteName));
    _projectList.clear();
    _projectList.addAll(projectListBkp);
    setState(() {});
  }

  void _setProjectToRemove({required Project project}) {
    TebDialog(context: context).confirmationDialog(message: 'Excluir este projeto?').then((value) {
      if (value == true) {
        if (project.id.isEmpty) {
          setState(() => _projectList.remove(project));
        } else {
          setState(() => project.setToRemove());
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
      var projectController = ProjectsController();
      TebReturn retorno;
      try {
        retorno = await projectController.save(projectList: _projectList);

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

  String? _textEditValidator(String? value, String errorMessage) {
    var finalValue = value ?? '';
    if (finalValue.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  Widget _imageArea({required Project project}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.11,
      child: Column(
        children: [
          // se carregou imagem
          if (project.image != null) Image(image: project.image!, fit: BoxFit.contain),
          if (project.image == null)
            (project.externalImageUrl.isEmpty && project.firestorageImageUrl.isEmpty) ||
                    (project.firestorageImageUrl.isNotEmpty && project.removeFirestorageImage)
                ? Image.asset('assets/images/no_image.gif')
                : Image.network(
                    project.externalImageUrl.isNotEmpty
                        ? project.externalImageUrl
                        : project.firestorageImageUrl,
                    fit: BoxFit.contain,
                  ),
          const SizedBox(height: 10),
          TebFilePickerWeb(
            buttonLabel: 'Imagem',
            icon: Icon(FontAwesomeIcons.image, color: Theme.of(context).colorScheme.surface),
            onPicked: (image) {
              project.removeFirestorageImage = false;
              setState(() => project.image = image);
            },
          ),
          TebButton(
            icon: Icon(FontAwesomeIcons.trashCan, color: Theme.of(context).colorScheme.surface),
            label: 'Remover Imagem',
            onPressed: () {
              if (project.firestorageImageUrl.isNotEmpty) {
                setState(() => project.removeFirestorageImage = true);
              }

              if (project.image != null) {
                setState(() => project.image = null);
              }
            },
            padding: const EdgeInsets.only(top: 10),
          ),
        ],
      ),
    );
  }

  Widget _prjectItem({required Project project}) {
    final size = MediaQuery.of(context).size;

    final TextEditingController orderController =
        TextEditingController(text: project.order.toString());
    final TextEditingController titleController = TextEditingController(text: project.title);
    final TextEditingController descriptionController =
        TextEditingController(text: project.description);
    final TextEditingController externalImageUrlController =
        TextEditingController(text: project.externalImageUrl);
    final TextEditingController urlController = TextEditingController(text: project.url);
    final TextEditingController urlGitHubController =
        TextEditingController(text: project.urlGithub);
    final TextEditingController tag1Controller = TextEditingController(text: project.tag1);
    final TextEditingController tag2Controller = TextEditingController(text: project.tag2);
    final TextEditingController tag3Controller = TextEditingController(text: project.tag3);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // image
          _imageArea(project: project),
          // text info
          SizedBox(
            width: size.width * 0.52,
            child: Column(
              children: [
                Row(
                  children: [
                    TebTextEdit(
                      width: size.width * 0.05,
                      labelText: 'Ordem',
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      onSave: (value) => project.order = int.tryParse(value ?? '') ?? 0,
                      onChanged: (value) => project.order = int.tryParse(value ?? '') ?? 0,
                      validator: (value) => _textEditValidator(value, 'Informe a ordem'),
                    ),
                    const Spacer(),
                    TebTextEdit(
                      width: size.width * 0.46,
                      labelText: 'Titulo',
                      controller: titleController,
                      onSave: (value) => project.title = value ?? '',
                      onChanged: (value) => project.title = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o título'),
                    ),
                  ],
                ),
                TebTextEdit(
                  labelText: 'Descrição',
                  prefixIcon: FontAwesomeIcons.fileLines,
                  controller: descriptionController,
                  onSave: (value) => project.description = value ?? '',
                  onChanged: (value) => project.description = value ?? '',
                  validator: (value) => _textEditValidator(value, 'Informe a descrição'),
                ),
                TebTextEdit(
                  labelText: 'URL para o projeto',
                  prefixIcon: FontAwesomeIcons.link,
                  controller: urlController,
                  onSave: (value) => project.url = value ?? '',
                  onChanged: (value) => project.url = value ?? '',
                  validator: (value) => _textEditValidator(value, 'Informe a url para o projeto'),
                ),
                TebTextEdit(
                  labelText: 'URL para o Github projeto',
                  prefixIcon: FontAwesomeIcons.github,
                  controller: urlGitHubController,
                  onSave: (value) => project.urlGithub = value ?? '',
                  onChanged: (value) => project.urlGithub = value ?? '',
                  //validator: (value) => _textEditValidator(value, 'Informe a url do Github do projeto'),
                ),
                TebTextEdit(
                  enabled: project.image == null,
                  labelText:
                      project.image == null ? 'URL da Imagem' : 'Utilizando a imagem carregada',
                  controller: externalImageUrlController,
                  onSave: (value) => project.externalImageUrl = value ?? '',
                  onChanged: (value) => setState(() => project.externalImageUrl = value ?? ''),
                  validator: (value) =>
                      project.image != null || project.firestorageImageUrl.isNotEmpty
                          ? null
                          : _textEditValidator(value, 'Informe a url da imagem'),
                ),
                Row(
                  children: [
                    TebTextEdit(
                      width: 150,
                      labelText: 'TAG 1 ',
                      controller: tag1Controller,
                      onSave: (value) => project.tag1 = value ?? '',
                      onChanged: (value) => project.tag1 = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o TAG 1'),
                      padding: const EdgeInsets.only(right: 5),
                    ),
                    TebTextEdit(
                      width: 150,
                      labelText: 'TAG 2',
                      controller: tag2Controller,
                      onSave: (value) => project.tag2 = value ?? '',
                      onChanged: (value) => project.tag2 = value ?? '',
                      validator: (value) => _textEditValidator(value, 'Informe o TAG 2'),
                      padding: const EdgeInsets.only(left: 5, right: 5),
                    ),
                    TebTextEdit(
                      width: 150,
                      labelText: 'TAG 3',
                      controller: tag3Controller,
                      onSave: (value) => project.tag3 = value ?? '',
                      onChanged: (value) => project.tag3 = value ?? '',
                      //validator: (value) => _textEditValidator(value, 'Informe o TAG 3'),
                      padding: const EdgeInsets.only(left: 5),
                    ),
                    SizedBox(
                      width: 240,
                      child: TebCheckBox(
                        title: 'Feito em família',
                        value: project.family,
                        onChanged: (value) => setState(() => project.family = value ?? false),
                      ),
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
                  icon: FaIcon(FontAwesomeIcons.trashCan,
                      color: Theme.of(context).colorScheme.surface),
                  onPressed: () => _setProjectToRemove(project: project),
                  enabled: project.status != ProjectStatus.delete,
                ),
                if (project.status == ProjectStatus.delete)
                  const TebText(
                    'Excluído',
                    padding: EdgeInsets.all(8),
                  ),
                const SizedBox(height: 8),
                TebButton(
                  label: 'Texto no site',
                  buttonType: TebButtonType.outlinedButton,
                  icon: FaIcon(
                    _idsWithContent.contains(project.id) ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.penToSquare,
                    size: 16,
                  ),
                  enabled: project.id.isNotEmpty && project.status != ProjectStatus.delete,
                  onPressed: () => _openContentEditor(project),
                ),
                if (project.id.isEmpty)
                  const TebText('Salve antes de escrever o texto', fontSize: 11, padding: EdgeInsets.all(4)),
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
      ProjectsController().getData(siteName: Consts.siteName).then((projectList) {
        _projectList.clear();
        if (projectList.isEmpty) projectList.add(Project(siteName: Consts.siteName));
        setState(() => _projectList.addAll(projectList));
      });
      _loadContentStatus();
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
                  icon: FaIcon(FontAwesomeIcons.floppyDisk,
                      color: Theme.of(context).colorScheme.surface),
                  onPressed: () => _submit(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // intro text title
            Row(
              children: [
                const TebText('Projetos', fontSize: 20),
                const Spacer(),
                TebButton(
                  label: 'Adicionar novo projeto',
                  icon: FaIcon(FontAwesomeIcons.plus, color: Theme.of(context).colorScheme.surface),
                  onPressed: () => _addProjectList(),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.8,
              width: size.width * 0.78,
              child: ListView.builder(
                itemCount: _projectList.length,
                itemBuilder: (itemBuildercontext, index) {
                  return _prjectItem(project: _projectList[index]);
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
