import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../provider/auth_provider.dart';
import '../../provider/teacher/provider_degree_teacher.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class ExamTeacherAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getExamsSchedule(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get(
          '${mainApi}teacher/exams/class_school/${data['class_school']}/study_year/${data['study_year']}',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (!response.body["error"]) {
        Get.put(ExamsTeacherProvider()).changeLoading(false);
        Get.put(ExamsTeacherProvider()).insertData(response.body['results']);
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

class DegreeTeacherAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getExamsDegree(String? subjectId, String? year) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get(
          '${mainApi}teacher/degrees/subject_id/$subjectId/study_year/$year',
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        EasyLoading.dismiss();
        return response.body;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getSchoolDegree(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await post(
          '${mainApi}teacher/degrees/class_school', data,
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        EasyLoading.dismiss();
        return response.body;
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  getStudentListDegrees(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await post('${mainApi}teacher/degrees/getData', data,
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        EasyLoading.dismiss();
        return response.body['results'];
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }

  insertDegrees(Map data) async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await post('${mainApi}teacher/degrees/addDegrees', data,
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else {
        EasyLoading.dismiss();
        return response.body['results'];
      }
    } catch (e) {
      Get.snackbar("error", 'Error in connection',
          colorText: MyColor.white0, backgroundColor: MyColor.red);
    }
  }
}
