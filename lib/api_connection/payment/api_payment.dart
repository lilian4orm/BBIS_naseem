import 'package:BBInaseem/provider/student/provider_salary.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../provider/auth_provider.dart';
import '../../static_files/my_url.dart';
import '../auth_connection.dart';

class PaymentApi extends GetConnect {
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  sendStudentSalaryAmount(Map data) async {
    Get.put(StudentSalaryProvider()).addPaymentRequestData(null);
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    Get.put(StudentSalaryProvider()).changePaymentLoading(true);

    //study_year
    try {
      final response = await post(
          '${mainApi}student/salary/pay_installments', data,
          headers: headers);
      if (response.statusCode == 401) {
        Auth().redirect();
      } else if (response.body["error"] == false) {
        Get.put(StudentSalaryProvider()).changePaymentLoading(false);
        Get.put(StudentSalaryProvider()).addPaymentRequestData(response.body);
      } else {
        Get.snackbar("تنبيه", response.body["message"] ?? "حدث خطأ ما");
        Get.put(StudentSalaryProvider()).changePaymentLoading(false);

        return {"error": true};
      }
    } catch (e) {
      Logger().e(e);
      Get.snackbar("تنبيه", "حدث خطأ ما");
      Get.put(StudentSalaryProvider()).changePaymentLoading(false);

      return {"error": true};
    }
  }
}
