import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:BBInaseem/api_connection/student/api_dashboard_data.dart';
import '../provider/auth_provider.dart';
import '../screens/auth/login_page.dart';
import '../static_files/my_color.dart';
import '../static_files/my_url.dart';
import 'package:dio/dio.dart' as dio;

class Auth extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  login(Map data) async {
    final response = await post('${mainApi}login', data);
    return response.body;
  }

  loginOut([String? token]) async {
    Map<String, String> headers = {
      "Authorization": token ?? dataProvider?['token']
    };
    final response = await get('${mainApi}logout', headers: headers);
    if (response.status.hasError) {
      return {"error": true};
    } else {
      final box = GetStorage();
      box.erase();
      return response.body;
    }
  }

  getStudentInfo() async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get('${mainApi}mainData', headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        if (response.body['error'] == false) {
          Get.put(MainDataGetProvider())
              .changeContentUrl(response.body['content_url']);
          Get.put(MainDataGetProvider()).addData(response.body['results']);
          followTopics();

          return response.body['results'];
        }
      }
    } catch (e) {
      showNoInternetDialog();
    }
  }

  void showNoInternetDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('error'),
        content: const Text('Please Check Your Internet Connection'),
        actions: [
          TextButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () {
              Get.close(1);
              Auth().getStudentInfo();
              DashboardDataAPI().latestNews();
            },
            child: const Center(
                child: Text(
              'Try Again',
              style: TextStyle(color: Colors.white),
            )),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  redirect() {
    final box = GetStorage();
    box.erase();
    Get.offAll(() => const LoginPage());
  }

  getIp() async {
    final response = await get("http://ip-api.com/json/?fields=93179");
    return response.body;
  }

  insertStudentInfo(dio.FormData data) async {
    final Map? dataProvider = Get.put(TokenProvider()).userData;
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await dio.Dio().post(
        '${mainApi}student/editInfo',
        data: data,
        options: dio.Options(headers: headers),
        onSendProgress: (int sent, int total) {
          if (sent == total) {
            Get.snackbar("success".tr, "file uploaded success".tr,
                colorText: MyColor.white0, backgroundColor: MyColor.green);
          }
        },
      );
      if (response.statusCode == 401) {
        redirect();
      } else {
        return response.data;
      }
    } catch (e) {
      Get.snackbar("خطأ", 'يوجد خطأ من السيرفر',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }
}
