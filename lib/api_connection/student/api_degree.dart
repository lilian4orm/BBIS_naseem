import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../provider/auth_provider.dart';
import '../../provider/student/provider_degree.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class DegreeStudentAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getExamsSchedule(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get(
          '${mainApi}student/exams/class_school/${data['class_school']}/study_year/${data['study_year']}',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(ExamsProvider()).changeLoading(false);
        Get.put(ExamsProvider()).insertData(response.body['results']);
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

  getExamsDegree(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get(
          '${mainApi}student/degrees/class_school/${data['class_school']}/study_year/${data['study_year']}',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(DegreeProvider()).changeLoading(false);
        Get.put(DegreeProvider()).insertData(response.body['results']);
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
