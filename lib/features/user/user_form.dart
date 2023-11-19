// ignore_for_file: use_build_context_synchronously

import 'package:marcosmhs/features/main/main_area_structure.dart';
import 'package:marcosmhs/features/main/routes.dart';
import 'package:marcosmhs/features/user/user.dart';
import 'package:marcosmhs/features/user/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  var _saveingData = false;
  var _initializing = true;

  var _user = User();

  void _submit() async {
    if (_saveingData) return;

    _saveingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _saveingData = false;
    } else {
      // salva os dados
      _formKey.currentState?.save();
      var userController = UserController();
      TebCustomReturn retorno;
      try {
        retorno = await userController.save(user: _user);
        if (retorno.returnType == TebReturnType.sucess) {
          TebCustomMessage.sucess(context, message: 'Dados Alterado com sucesso');
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

  void _initialization() {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      _user = User.fromMap(map: _user.toMap());

      _emailController.text = _user.email;
      _nameController.text = _user.name;

      _initializing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialization();
    final Size size = MediaQuery.of(context).size;
    return MainAreaStructure(
        mobile: size.width < 1000,
        user: _user,
        size: size,
        widget: Form(
          key: _formKey,
          child: Column(
            children: [
              // name
              TebTextEdit(
                context: context,
                controller: _nameController,
                labelText: 'Nome',
                hintText: 'Informe seu nome',
                onSave: (value) => _user.name = value ?? '',
                prefixIcon: Icons.person,
                textInputAction: TextInputAction.next,
                focusNode: _nameFocus,
                nextFocusNode: _emailFocus,
                validator: (value) {
                  final finalValue = value ?? '';
                  if (finalValue.trim().isEmpty) return 'O nome deve ser informado';
                  return null;
                },
              ),
              // registration
              TebTextEdit(
                context: context,
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Seu e-mail',
                onSave: (value) => _user.email = value ?? '',
                prefixIcon: Icons.person,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _emailFocus,
                nextFocusNode: _passwordFocus,
                validator: (value) {
                  final finalValue = value ?? '';
                  if (finalValue.trim().isEmpty) return 'O e-mail deve ser informado';
                  return null;
                },
              ),
              // password
              TebTextEdit(
                context: context,
                controller: _passwordController,
                labelText: 'Senha',
                hintText: 'Informe sua senha',
                isPassword: true,
                onSave: (value) {
                  if (value != null && value.isNotEmpty) {
                    _user.setPassword(value);
                  }
                },
                prefixIcon: Icons.lock,
                textInputAction: TextInputAction.next,
                focusNode: _passwordFocus,
                nextFocusNode: _confirmPasswordFocus,
                validator: (value) {
                  final finalValue = value ?? '';
                  // em uma edição a checagem só deve ser feita se houve edição
                  if (finalValue.trim().isNotEmpty && _confirmPasswordController.text.isNotEmpty) {
                    if (finalValue.trim().isEmpty) return 'Informe a senha';
                    if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                    if (finalValue != _confirmPasswordController.text) return 'As senhas digitadas não são iguais';
                  }

                  return null;
                },
              ),
              // password confirmation
              TebTextEdit(
                context: context,
                controller: _confirmPasswordController,
                labelText: 'Repita a senha',
                hintText: 'Informe sua senha novamente',
                isPassword: true,
                prefixIcon: Icons.lock,
                textInputAction: TextInputAction.next,
                focusNode: _confirmPasswordFocus,
                validator: (value) {
                  final finalValue = value ?? '';
                  if (finalValue.trim().isNotEmpty && _passwordController.text.isNotEmpty) {
                    if (finalValue.trim().isEmpty) return 'Informe a senha';
                    if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                    if (finalValue != _passwordController.text) return 'As senhas digitadas não são iguais';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              // Buttons
              TebButtonsLine(
                buttons: [
                  TebButton(
                    label: 'Cancelar',
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                  TebButton(label: 'Confirmar', onPressed: _submit),
                ],
              ),
            ],
          ),
        ));
  }
}
