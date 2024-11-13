import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:logger/logger.dart';
import '../../../provider/auth_provider.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_url.dart';
import '../../auth_connection.dart';
import 'package:dio/dio.dart';

class ChatGroupListAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getGroupList() async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await get('${mainApi}teacher/chatGroup/get', headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        Logger().i(response.body);
        return response.body;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getChatOfGroup(String groupId, int page) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get(
          '${mainApi}teacher/chatGroup/messages/groupId/$groupId/page/$page',
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

  createGroup(dio.FormData data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await dio.Dio().post(
        '${mainApi}teacher/chatGroup/create',
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
      if (response.data['error'] == false) {
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

  editGroup(dio.FormData data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    Logger().i(headers);
    try {
      final response = await dio.Dio().put(
        '${mainApi}teacher/chatGroup/edit',
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
      if (response.data['error'] == false) {
        EasyLoading.showSuccess(response.data['message'].toString());
      } else {
        EasyLoading.showError(response.data['message'].toString());
      }
      return response.data;
    } catch (e) {
      Logger().i(e);
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  Future<dynamic> deleteGroup(String id) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await dio.Dio().delete(
        '${mainApi}teacher/chatGroup/remove/$id',
        options: dio.Options(headers: headers),
      );
      if (response.data['error'] == false) {
        EasyLoading.showSuccess(response.data['message'].toString());
        return response.data;
      } else {
        EasyLoading.showError(response.data['message'].toString());
      }
      return response.data;
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  Future<bool> getChatGroupLockStatus(String groupId) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};

    try {
      final response = await Dio().put(
        '${mainApi}teacher/chatGroup/is_locked',
        data: {"_id": groupId},
        options: Options(headers: headers),
      );

      if (response.statusCode == 401) {
        Auth().redirect();
        return false; // Handle unauthorized access as needed.
      } else {
        Logger().i(response.data);
        if (response.data['error'] == false) {
          // Lock status is based on the API response.
          return response.data['is_locked'] ?? false;
        } else {
          EasyLoading.showError(response.data['message'].toString());
          return false;
        }
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
      return false;
    }
  }

  Future<void> updateChatGroupLockStatus(String groupId, bool isLocked) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};

    try {
      final response = await Dio().put(
        '${mainApi}teacher/chatGroup/is_locked',
        data: {"_id": groupId, "is_locked": isLocked},
        options: Options(headers: headers),
      );

      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        Logger().i(response.data);
        if (response.data['error'] == false) {
          EasyLoading.showSuccess(response.data['message'].toString());
        } else {
          EasyLoading.showError(response.data['message'].toString());
        }
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }
}
