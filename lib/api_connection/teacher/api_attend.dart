import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../provider/auth_provider.dart';
import '../../provider/teacher/provider_attend.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class AttendAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getAttend(Map data) async {
    EasyLoading.show(status: "Loading ...");
    Map<String, String> headers = {"Authorization": dataProvider!['token']};

    try {
      final response =
          await post('${mainApi}teacher/absence', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Get.put(TeacherAttendProvider()).changeLoading(false);

        Get.put(TeacherAttendProvider()).addAttendCount(
            response.body['results']['absence'],
            response.body['results']['vacation'],
            response.body['results']['presence'],
            response.body['results']['forThisMonth']['presence']);
        Get.put(TeacherAttendProvider())
            .addToList(response.body['results']['data']);
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

  addAttend(String? id) async {
    String studyYear =
        Get.put(MainDataGetProvider()).mainData['setting'][0]['setting_year'];
    EasyLoading.show(status: "Adding Check ...");
    Map<String, String> headers = {"Authorization": dataProvider!['token']};

    try {
      final response = await get(
          '${mainApi}teacher/absence/qr/$id/study_year/$studyYear',
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
