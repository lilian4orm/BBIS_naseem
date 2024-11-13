import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../provider/student/provider_genral_data.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';

class GeneralData extends GetConnect {
  getAds(int page) async {
    try {
      final response = await get('${mainApi}ads/page/$page');
      if (!response.body['error']) {
        Get.put(AdsProvider()).changeLoading(false);
        Get.put(AdsProvider()).changeContentUrl(response.body['content_url']);
        Get.put(AdsProvider()).addData(response.body['results']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getSchools() async {
    try {
      final response = await get('${mainApi}schools');
      if (!response.body['error']) {
        Get.put(SchoolsProvider()).changeLoading(false);
        Get.put(SchoolsProvider()).addData(response.body['results']);
        return response.body['results'];
      } else {
        return false;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getGovernorate() async {
    try {
      final response = await get('${mainApi}governorate');
      if (!response.body['error']) {
        Get.put(SchoolsProvider()).changeLoading(false);
        Get.put(SchoolsProvider()).addData(response.body['results']);
        return response.body['results'];
      } else {
        return false;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getContact() async {
    try {
      final response =
          await get('${mainApi}schools/id/668babba8f398d95a87b051b');
      if (!response.body['error']) {
        Get.put(ContactProvider()).changeLoading(false);
        Get.put(ContactProvider())
            .changeContentUrl(response.body['content_url']);
        Get.put(ContactProvider()).addData(response.body['results']);
      } else {
        return false;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  hireRequest(Map data) async {
    try {
      //todo static url request jop
      final response = await dio.Dio().post(
        'https://api.jasmine-k.com/api/web/school/work_register', data: data,
        onSendProgress: (int sent, int total) {
          EasyLoading.showProgress(sent / total, status: "Uploading ...");
          if (sent == total) {
            EasyLoading.instance.userInteractions = true;
            EasyLoading.showSuccess("Uploaded Done", dismissOnTap: true);
            Timer(const Duration(seconds: 2), () {
              EasyLoading.dismiss();
            });
          }
        },
        // uploadProgress: (progress) {
        //   double _newProgress = double.parse(progress.toStringAsFixed(1));
        //   EasyLoading.showProgress(_newProgress / 100, status: "جار الرفع...");
        //   if (_newProgress == 100.0) {
        //     EasyLoading.instance.userInteractions = true;
        //     EasyLoading.showSuccess("تم الرفع بنجاح", dismissOnTap: true);
        //     Timer(const Duration(seconds: 2), () {
        //       EasyLoading.dismiss();
        //     });
        //   }
        // }
      );
      if (response.data['error']) {
        EasyLoading.show(status: response.data['message'], dismissOnTap: true);
        return {"error": true};
      } else {
        return response.data;
      }
    } catch (e) {
      log(e.toString());
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  joinUsSchool(Map data) async {
    try {
      final response = await post('${mainApi}student/register/school', data);
      return response.body;
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  joinUsKindergarten(Map data) async {
    try {
      final response = await post('${mainApi}student/register', data);
      return response.body;
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  // getSubject(String _subjectName) async {
  //   Map _data = {
  //     "className" : _subjectName
  //   };
  //   try {
  //     final response = await post(MyUrl().apiUrl + 'classes/subject',_data);
  //     if (!response.body['error']) {
  //       Get.put(SubjectProvider()).changeContentUrl(response.body['content_url']);
  //       Get.put(SubjectProvider()).addToSubject(response.body['results']);
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     Get.snackbar("خطأ".tr, 'الرجاء التاكد من اتصالك في الانترنت', colorText: MyColor.white, backgroundColor: MyColor.red);
  //   }
  // }
  //
  // getTeachers(Map _data) async {
  //   try {
  //     final response = await post(MyUrl().apiUrl + 'getTeachersBySubject',_data);
  //     if (!response.body['error']) {
  //       Get.put(TeachersProvider()).changeContentUrl(response.body['content_url']);
  //       Get.put(TeachersProvider()).addToTeachers(response.body['results']);
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     Get.snackbar("خطأ".tr, 'الرجاء التاكد من اتصالك في الانترنت', colorText: MyColor.white, backgroundColor: MyColor.red);
  //   }
  // }
}
