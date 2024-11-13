import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../provider/auth_provider.dart';
import '../../provider/teacher/provider_weekly_schedule.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class WeeklyScheduleAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getSchedule(String id) async {
    EasyLoading.show(status: "Loading ...");
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get('${mainApi}teacher/schedule/class_school/$id',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Get.put(TeacherWeeklyScheduleProvider()).changeLoading(false);
        Get.put(TeacherWeeklyScheduleProvider())
            .addData(response.body['results']);
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
