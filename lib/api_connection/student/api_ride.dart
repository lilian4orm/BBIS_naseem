import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../provider/auth_provider.dart';
import '../../provider/student/provider_ride.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class StudentRideAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getRides(Map data) async {
    EasyLoading.show(status: "Loading ...");
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await post('${mainApi}student/rides', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Logger().i(response.body['results']);
        Get.put(StudentRideProvider()).addData(response.body['results']);
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
//localhost:3400/api/mobile/student/salary/study_year/2021-2022
