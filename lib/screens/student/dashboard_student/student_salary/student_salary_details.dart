import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../api_connection/student/api_salary.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/student/provider_salary.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_loading.dart';

class StudentSalaryDetails extends StatefulWidget {
  const StudentSalaryDetails({super.key});

  @override
  State<StudentSalaryDetails> createState() => _StudentSalaryDetailsState();
}

class _StudentSalaryDetailsState extends State<StudentSalaryDetails> {
  _getData() {
    String year =
        Get.put(MainDataGetProvider()).mainData['setting'][0]['setting_year'];
    StudentSalaryAPI().getFullSalary(year);
  }

  final formatter = NumberFormat.decimalPattern();
  DateTime now = DateTime.now();
  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('instsDetailes'.tr),
      body: GetBuilder<StudentFullSalaryProvider>(builder: (val) {
        return val.isLoading
            ? loading()
            : val.data.isEmpty
                ? EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_1,
                    title: 'nodta'.tr,
                    subTitle: 'noIstAdd'.tr,
                    titleTextStyle: const TextStyle(
                      fontSize: 22,
                      color: Color(0xff9da9c7),
                      fontWeight: FontWeight.w500,
                    ),
                    subtitleTextStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xffabb8d6),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: val.data.length,
                    itemBuilder: (BuildContext context, int indexes) {
                      return Card(
                        child: Column(
                          children: [
                            listTile(val.data[indexes]['service_type'],
                                "type".tr, null),
                            listTile(
                                val.data[indexes]['date'], "date".tr, null),
                            if (val.data[indexes]['desc'] != null)
                              listTile(val.data[indexes]['desc'], "details".tr,
                                  null),
                            listTile(
                                formatter
                                    .format(val.data[indexes]['salaryAmount']),
                                "amount".tr,
                                val.data[indexes]['currencySymbol']),
                            listTile(
                                formatter
                                    .format(val.data[indexes]['paymentAmount']),
                                "paid".tr,
                                val.data[indexes]['currencySymbol']),
                            listTile(
                                formatter.format(
                                    val.data[indexes]['discountAmount']),
                                "discount".tr,
                                val.data[indexes]['currencySymbol']),
                            listTile(
                                formatter
                                    .format(val.data[indexes]['remaining']),
                                "rem".tr,
                                val.data[indexes]['currencySymbol']),
                          ],
                        ),
                      );
                    });
      }),
    );
  }
}

ListTile listTile(String title, String leading, String? trailing) {
  return ListTile(
    title: Text(title),
    leading: Text(leading),
    trailing: trailing == null ? null : Text(trailing),
  );
}
