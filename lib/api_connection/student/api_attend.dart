import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../provider/auth_provider.dart';
import '../../provider/student/attend_provider.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class AttendAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getAttend(Map data) async {
    EasyLoading.show(status: "Loading ...");
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    //study_year
    try {
      final response =
          await post('${mainApi}student/absence', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Get.put(StudentAttendProvider()).changeLoading(false);
        Get.put(StudentAttendProvider()).addAttendCount(
            response.body['results']['absence'],
            response.body['results']['vacation'],
            response.body['results']['presence'],
            response.body['results']['forThisMonth']['presence']);
        Get.put(StudentAttendProvider())
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
}
