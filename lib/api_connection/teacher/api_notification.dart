import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../../provider/auth_provider.dart';
import '../../provider/teacher/provider_notification.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class NotificationsAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getNotifications(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await post('${mainApi}teacher/notification', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(TeacherNotificationProvider()).changeLoading(false);
        Get.put(TeacherNotificationProvider())
            .changeContentUrl(response.body['content_url']);
        Get.put(TeacherNotificationProvider()).changeCount(
            response.body['results']['count_all'],
            response.body['results']['count_read'],
            response.body['results']['count_unread']);
        Get.put(TeacherNotificationProvider())
            .insertData(response.body['results']['data']);
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
        return {"error": true};
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  updateReadNotifications(String id) async {
    Map data = {"notification_id": id};
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await put('${mainApi}teacher/notification', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(TeacherNotificationProvider()).editReadMap(id);
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  addNotification(dio.FormData data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await dio.Dio().post(
        '${mainApi}teacher/notification/add',
        data: data,
        options: dio.Options(headers: headers),
        onSendProgress: (int sent, int total) {
          EasyLoading.showProgress(sent / total, status: "Uploading ...");
          if (sent == total) {
            EasyLoading.instance.userInteractions = true;
            EasyLoading.showSuccess("Uploaded Done", dismissOnTap: true);
            Timer(const Duration(seconds: 1), () {});
          }
        },
      );
      if (!response.data['error']) {
        EasyLoading.showSuccess(response.data['message'].toString());
      } else {
        EasyLoading.showError(response.data['message'].toString());
      }
      return response.data;
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  deleteNotification(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await post('${mainApi}teacher/notification/remove', data,
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(TeacherNotificationProvider())
            .deleteNotification(data["notifications_id"]);
        EasyLoading.showSuccess("Notification Deleted");
      } else {
        EasyLoading.dismiss();
        return {"error": true};
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getHomeworkAnswers(String notificationId, int page) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get(
          '${mainApi}teacher/homeworkAnswers/notification_id/$notificationId/page/$page',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(TeacherHomeworkAnswersProvider()).changeLoading(false);
        Get.put(TeacherHomeworkAnswersProvider())
            .changeContentUrl(response.body['content_url']);
        Get.put(TeacherHomeworkAnswersProvider())
            .insertData(response.body['results']['data']);
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
        return {"error": true};
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  addCorrect(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await put('${mainApi}teacher/homeworkAnswers', data,
          headers: headers);
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
}
