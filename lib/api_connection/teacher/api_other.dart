import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../provider/auth_provider.dart';
import '../../provider/teacher/provider_other.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class OtherApi extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getStudent(Map data, bool showLoading) async {
    if (showLoading) {
      EasyLoading.show(status: "Loading");
    }
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await post('${mainApi}teacher/students', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Get.put(OtherProvider()).addToList(response.body['results']);
        EasyLoading.dismiss();
        return response.body['results'];
      } else {
        EasyLoading.dismiss();
        return {"error": true};
      }
    } catch (e) {
      Get.snackbar("Error", 'Check your network connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getNotificationList() async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await get('${mainApi}teacher/notificationList', headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        //Get.put(OtherProvider()).addToList(response.body['results']);
        EasyLoading.dismiss();
        return response.body['results'];
      } else {
        EasyLoading.dismiss();
        return {"error": true};
      }
    } catch (e) {
      Get.snackbar("Error", 'Check your network connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }
}
