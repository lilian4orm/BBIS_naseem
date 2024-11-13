import 'package:BBInaseem/update_files/check_update_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreenWellcome extends StatefulWidget {
  const SplashScreenWellcome({super.key});

  @override
  State<SplashScreenWellcome> createState() => _SplashScreenWellcomeState();
}

class _SplashScreenWellcomeState extends State<SplashScreenWellcome> {
  CheckUpdateController controller = Get.put(CheckUpdateController());
  @override
  void initState() {
    super.initState();
    controller.checkAndUpdateApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/img/logo.png'),
        ],
      ),
    );
  }
}
