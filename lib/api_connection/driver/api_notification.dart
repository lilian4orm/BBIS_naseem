import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../provider/auth_provider.dart';
import '../../provider/driver/provider_notification.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class NotificationsAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getNotifications(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await post('${mainApi}driver/notification', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(NotificationDriverProvider()).changeLoading(false);
        Get.put(NotificationDriverProvider())
            .changeContentUrl(response.body['content_url']);
        Get.put(NotificationDriverProvider())
            .insertData(response.body['results']);
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
          await put('${mainApi}driver/notification', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(NotificationDriverProvider()).editReadMap(id);
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }
}
