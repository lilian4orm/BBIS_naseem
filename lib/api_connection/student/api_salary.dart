import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../provider/auth_provider.dart';
import '../../provider/student/provider_salary.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class StudentSalaryAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getSalary(String year) async {
    EasyLoading.show(status: "Loading ...");
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get('${mainApi}student/salary/study_year/$year',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Get.put(StudentSalaryProvider()).changeLoading(false);
        Get.put(StudentSalaryProvider()).addData(response.body['results']);
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

  getFullSalary(String year) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get(
          '${mainApi}student/salary/details/study_year/$year',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(StudentFullSalaryProvider()).changeLoading(false);
        Get.put(StudentFullSalaryProvider()).addData(response.body['results']);
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
        return {"error": true};
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }
}
