import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../provider/auth_provider.dart';
import '../../provider/driver/provider_rides_students.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class RidesStudentsAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getStudents() async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get('${mainApi}driver/rides', headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Logger().i(response.body['results']);
        Get.put(RidesStudentsProvider()).changeLoading(false);
        Get.put(RidesStudentsProvider()).insertData(response.body['results']);
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

  addStudentStatus(String studentId, String type) async {
    Map data = {"student_id": studentId, "status": type};
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await post('${mainApi}driver/rides', data, headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        EasyLoading.showSuccess(response.body['message'].toString());
        getStudents();
      } else {
        EasyLoading.showError(response.body['message'].toString());
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }
}
