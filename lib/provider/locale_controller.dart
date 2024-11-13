import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// controller to set and change language
class MylocaleController extends GetxController {
  final box = GetStorage();

  Locale getInitLocale() {
    return box.read("language") == null
        ? const Locale(
            "en") // if the user didn't choose yet set the arabic language
        : Locale(
            box.read("language")!); // if he choosed get the language he choosed
  }

// function to transfer between arabic and english language
  void changeLanguage(String languageCode) {
    Locale locale = Locale(languageCode);
    box.write("language", languageCode);
    Get.updateLocale(locale);
  }
}
