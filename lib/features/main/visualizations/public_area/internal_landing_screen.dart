import 'package:flutter/material.dart';
import 'package:marcosmhs/features/main/hive_controller.dart';
//import 'package:marcosmhs/features/main/visualizations/home_desktop.dart';
//import 'package:marcosmhs/features/main/visualizations/home_mobile.dart';
import 'package:marcosmhs/features/main/visualizations/main_area.dart';
import 'package:marcosmhs/features/user/login_screen.dart';

class InternalLandingScreen extends StatefulWidget {
  const InternalLandingScreen({Key? key}) : super(key: key);

  @override
  State<InternalLandingScreen> createState() => _InternalLandingScreenState();
}

class _InternalLandingScreenState extends State<InternalLandingScreen> {
  Widget _errorScreen({required String errorMessage}) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Fatal error!'),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var hiveController = HiveController();

    return FutureBuilder(
      future: hiveController.chechLocalData(),
      builder: (ctx, snapshot) {
        // enquanto está carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          // em caso de erro
        } else {
          if (snapshot.error != null) {
            return _errorScreen(errorMessage: snapshot.error.toString());
            // ao final do processo
          } else {
            // irá avaliar se o usuário possui login ou não
            return hiveController.localUser.id.isEmpty
                ? LoginScreen(mobile: MediaQuery.of(context).size.width < 1000)
                : MainArea(user: hiveController.localUser);
          }
        }
      },
    );
  }
}
