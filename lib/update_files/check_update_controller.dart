import 'dart:convert';
import 'dart:io';

import 'package:BBInaseem/provider/auth_provider.dart';
import 'package:BBInaseem/screens/auth/login_page.dart';
import 'package:BBInaseem/screens/driver/driver_home.dart';
import 'package:BBInaseem/screens/student/student_home.dart';
import 'package:BBInaseem/screens/teacher/teacher_home.dart';
import 'package:BBInaseem/static_files/my_color.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:open_file/open_file.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class CheckUpdateController extends GetConnect {
  String link =
      'https://api.lm-uat.com/api/mobile/app_versions/نسيم';

  checkForNewVersion() async {
    try {
      final response = await http.get(Uri.parse(link));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        final latestVersion = data['results']['version'];
        final currentVersion = await getCurrentVersion();

        bool isNewVersionAvailable = latestVersion != currentVersion;

        EasyLoading.dismiss();

        if (isNewVersionAvailable) {
          EasyLoading.show(status: "تنزيل التحديث...");
          String url = data['results']['url'];

          final filePath =
              await downloadNewVersion("https://api.lm-uat.com/$url");
          EasyLoading.dismiss();

          await installNewVersion(filePath);
        } else {
          redirectToPage();
          Get.snackbar("نجاح", "تم التحديث الى اخر اصدار",
              colorText: MyColor.white0, backgroundColor: MyColor.green);
        }
        return;
      }
      return false;
    } catch (e) {
      EasyLoading.dismiss();
      redirectToPage();
    }
  }

  redirectToPage() {
    try {
      final box = GetStorage();
      Map? userData = box.read('_userData');
      if (userData == null) {
        Get.offAll(() => const LoginPage());
      } else if (userData["account_type"] == "student") {
        Get.put(TokenProvider()).addToken(userData);
        Get.offAll(() => HomePageStudent(userData: userData));
      } else if (userData["account_type"] == "driver") {
        Get.put(TokenProvider()).addToken(userData);
        Get.offAll(() => HomePageDriver(userData: userData));
      } else if (userData["account_type"] == "teacher") {
        Get.put(TokenProvider()).addToken(userData);
        Get.offAll(() => HomePageTeacher(userData: userData));
      } else {
        Get.offAll(() => const LoginPage());
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.offAll(() => const LoginPage());
    }
  }

  void checkAndUpdateApp() async {
    try {
      if (Platform.isAndroid) {
        EasyLoading.show(status: "التحقق من التحديث...");
        await checkForNewVersion();
      } else {
        redirectToPage();
      }
    } catch (e) {
      EasyLoading.dismiss();
      redirectToPage();
    }
  }

  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  Future<String> downloadNewVersion(String url) async {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory?.path}/new_version.apk';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> requestInstallPackagesPermission() async {
    try {
      if (await Permission.requestInstallPackages.isDenied) {
        await Permission.requestInstallPackages.request();
      }
    } catch (e) {
      EasyLoading.dismiss();
      redirectToPage();
    }
  }

  Future<void> installNewVersion(String filePath) async {
    try {
      await requestInstallPackagesPermission();

      await OpenFile.open(filePath);
    } catch (e) {
      EasyLoading.dismiss();
      redirectToPage();
    }
  }
}
