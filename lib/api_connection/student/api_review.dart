import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../provider/auth_provider.dart';
import '../../provider/student/provider_review.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class ReviewAPI extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  getReview() async {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response = await get('${mainApi}student/review', headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Get.put(ReviewDateProvider()).changeLoading(false);
        Get.put(ReviewDateProvider()).insertData(response.body['results']);
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

  addReview(String text, String reviewId) async {
    Map data = {"review_father_note": text, "review_id": reviewId};
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    try {
      final response =
          await put('${mainApi}student/review', data, headers: headers);
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
