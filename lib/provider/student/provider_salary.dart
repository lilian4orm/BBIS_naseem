import 'package:BBInaseem/api_connection/student/api_salary.dart';
import 'package:BBInaseem/provider/auth_provider.dart';
import 'package:BBInaseem/screens/shared/payment_web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentSalaryProvider extends GetxController {
  final salaryData = {}.obs;
  Map? paymantData = {};
  final isLoading = true.obs;
  final ammountController = TextEditingController().obs;
  final paymentLoading = false.obs;

  void changeLoading(bool isLoading) {
    this.isLoading.value = isLoading;
    notifyChildrens();
  }

  void changePaymentLoading(bool isLoading) {
    paymentLoading.value = isLoading;
    notifyChildrens();
  }

  void addData(Map data) {
    salaryData.value = data;
    notifyChildrens();
  }

  Future<void> addPaymentRequestData(Map? data) async {
    paymantData = data;
    if (paymantData != null) {
      final result = await Get.to(() => PaymentInAppWebViewScreen(
            url: paymantData!['redirect_url'] ?? '',
          ));
      if (result == true) {
        ammountController.value.clear();
        getData();
      }
    }

    update();
  }

  getData() {
    isLoading.value = true;
    notifyChildrens();
    String year =
        Get.put(MainDataGetProvider()).mainData['setting'][0]['setting_year'];
    StudentSalaryAPI().getSalary(year);
  }
}

class StudentFullSalaryProvider extends GetxController {
  List data = [];
  bool isLoading = true;
  void changeLoading(bool isLoading) {
    isLoading = isLoading;
  }

  void addData(List data) {
    data = data;
    update();
  }
}
