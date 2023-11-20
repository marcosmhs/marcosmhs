import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:marcosmhs/features/admin_area/user/user_controller.dart';

import 'package:teb_package/util/teb_return.dart';

class HiveController with ChangeNotifier {
  final _userHiveBoxName = 'user';
  late Box<dynamic> _userHiveBox;

  var _user = User();

  Future<void> _prepareUserHiveBox() async {
    if (!Hive.isBoxOpen(_userHiveBoxName)) {
      _userHiveBox = await Hive.openBox(_userHiveBoxName);
    } else {
      _userHiveBox = Hive.box(_userHiveBoxName);
    }
  }

  Future<void> chechLocalData() async {
    await _prepareUserHiveBox();
    if (_userHiveBox.isNotEmpty) {
      _user = _userHiveBox.get(_userHiveBox.keyAt(0));
    }

    var userController = UserController();

    if (_user.id.isEmpty) return;

    var result = await userController.login(user: _user);

    if (result.returnType == TebReturnType.error) {
      _user = User();
    } else {
      _user = userController.currentUser;
    }
  }

  Future<void> removeBox() async {
    await _prepareUserHiveBox();
    await _userHiveBox.deleteFromDisk();
  }

  User get localUser => User.fromMap(map: _user.toMap());

  void saveUser({required User user}) async {
    await _prepareUserHiveBox();
    await _userHiveBox.clear();
    await _userHiveBox.put(user.id, user);
  }

  void clearUserHiveBox() async {
    await _prepareUserHiveBox();
    await _userHiveBox.clear();
  }
}
