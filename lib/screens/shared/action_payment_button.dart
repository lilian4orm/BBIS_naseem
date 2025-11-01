import 'package:BBInaseem/api_connection/payment/api_payment.dart';
import 'package:BBInaseem/provider/student/provider_salary.dart';
import 'package:BBInaseem/screens/shared/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../provider/auth_provider.dart';
import '../../../../static_files/my_color.dart';

class PaymentActionButton extends StatefulWidget {
  const PaymentActionButton({
    super.key,
    required this.salaryId,
    required this.remining,
  });
  final String salaryId;
  final int remining;
  @override
  State<PaymentActionButton> createState() => _PaymentActionButtonState();
}

class _PaymentActionButtonState extends State<PaymentActionButton> {
  Position? position;
  late String year;
  final _formKey = GlobalKey<FormState>();
  final StudentSalaryProvider salaryProvider =
      Get.find<StudentSalaryProvider>();
  _getLocation() async {
    year =
        Get.put(MainDataGetProvider()).mainData['setting'][0]['setting_year'];

    position = await LocationService.getCurrentPosition();
    if (position == null) {
      Get.snackbar(
        "تنبيه",
        "الرجاء تفعيل خدمة الموقع",
      );
    }
  }

  _sendSalaryAmount() async {
    if (position == null) {
      _getLocation();
      return;
    }
    PaymentApi().sendStudentSalaryAmount({
      "study_year": year,
      "lat": position!.latitude,
      "lng": position!.longitude,
      "amount": int.parse(salaryProvider.ammountController.value.text),
      "salary_student_id": widget.salaryId,
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(
        () => Form(
            key: _formKey,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                const Text(
                  "ادخل المبلغ المراد تسديده",
                  style: TextStyle(
                      color: MyColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: size.width,
                  child: TextFormField(
                    controller: salaryProvider.ammountController.value,
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "الرجاء ادخال المبلغ";
                      }

                      if ((int.tryParse(value) ?? 0) < 1) {
                        return "الرجاء ادخال مبلغ صحيح";
                      }

                      if ((int.tryParse(value) ?? 0) > widget.remining) {
                        return "المبلغ اكبر من المتبقي";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "ادخل المبلغ",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: salaryProvider.paymentLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _sendSalaryAmount();
                          }
                        },
                  label: const Text("تسديد القسط"),
                  icon: salaryProvider.paymentLoading.value
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.payment,
                          size: 30,
                        ),
                )
              ],
            )),
      ),
    );
  }
}
