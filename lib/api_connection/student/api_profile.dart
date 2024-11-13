import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../provider/auth_provider.dart';
import 'package:dio/dio.dart' as dio;
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class StudentProfileAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  editImgProfile(dio.FormData data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await dio.Dio().put(
        '${mainApi}student/editImg',
        data: data,
        options: dio.Options(headers: headers),
        onSendProgress: (int sent, int total) {
          EasyLoading.showProgress(sent / total, status: "Uploading ...");
          if (sent == total) {
            EasyLoading.instance.userInteractions = true;
            EasyLoading.showSuccess("Uploaded Done", dismissOnTap: true);
            Timer(const Duration(seconds: 1), () {
              EasyLoading.dismiss();
            });
          }
        },
      );
      return response.data;
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  studentCertificateInsert(dio.FormData data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await dio.Dio().post(
        '${mainApi}student/certificate',
        data: data,
        options: dio.Options(headers: headers),
        onSendProgress: (int sent, int total) {
          EasyLoading.showProgress(sent / total, status: "Uploading ...");
          if (sent == total) {
            EasyLoading.instance.userInteractions = true;
            EasyLoading.showSuccess("Uploaded Done", dismissOnTap: true);
            Timer(const Duration(seconds: 1), () {
              EasyLoading.dismiss();
            });
          }
        },
      );
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        return response.data;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  studentCertificateGet() async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await get('${mainApi}student/certificate', headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        return response.body;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  Future<dynamic> editBirthdayAddressMobile(
      String mobile, String birthday, String address) async {
    final headers = {"Authorization": dataProvider!['token']};
    final data = {
      "account_mobile": mobile,
      "account_birthday": birthday,
      "account_address": address
    };

    try {
      final response = await dio.Dio().put(
        '${mainApi}student/editInfo/edit_birthday_address_mobile',
        data: data,
        options: dio.Options(headers: headers),
      );

      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        return response.data;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> deleteAcount() async {
    final headers = {"Authorization": dataProvider!['token']};

    try {
      final response = await dio.Dio().get(
        '${mainApi}profile/remove_account',
        options: dio.Options(headers: headers),
      );
      // print(response.data);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        return response.data;
      }
    } catch (e) {
      print(e);
    }
  }
}
