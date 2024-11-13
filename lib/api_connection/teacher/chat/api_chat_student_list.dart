import 'package:get/get.dart';

import '../../../provider/auth_provider.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_url.dart';
import '../../auth_connection.dart';

class ChatStudentListAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getStudentList(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await post('${mainApi}teacher/chat/students', data, headers: headers);
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

  getChatOfStudent(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await post('${mainApi}teacher/chat', data, headers: headers);
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
