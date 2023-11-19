import 'package:flutter/material.dart';
import 'package:marcosmhs/features/main/main_area_structure.dart';
import 'package:marcosmhs/features/user/user.dart';

class MainArea extends StatefulWidget {
  final User? user;
  const MainArea({Key? key, this.user}) : super(key: key);

  @override
  State<MainArea> createState() => _MainAreaState();
}

class _MainAreaState extends State<MainArea> {
  var _user = User();
  var _initializing = true;

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      if (widget.user == null) {
        final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
        _user = arguments['user'] ?? User();
      } else {
        _user = widget.user!;
      }
      _initializing = false;
    }

    final Size size = MediaQuery.of(context).size;
    return MainAreaStructure(
      mobile: size.width < 1000,
      user: _user,
      size: size,
      widget: const Center(child: Text('hoje')),
    );
  }
}
