import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../api_connection/student/api_salary.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/student/provider_salary.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_loading.dart';
import 'student_salary_details.dart';

class StudentSalary extends StatefulWidget {
  const StudentSalary({super.key});

  @override
  State<StudentSalary> createState() => _StudentSalaryState();
}

class _StudentSalaryState extends State<StudentSalary> {
  _getData() {
    String year =
        Get.put(MainDataGetProvider()).mainData['setting'][0]['setting_year'];
    StudentSalaryAPI().getSalary(year);
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
      appBar: myAppBar('Installments'.tr),
      body: GetBuilder<StudentSalaryProvider>(builder: (val) {
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
                : Column(
                    children: [
                      _listTile(
                          //
                          'totYearInstallment'.tr,
                          "${formatter.format(val.data['forThisYear']['salaryAmount'])} ${val.data['forThisYear']['currencySymbol']}", //${val.currencySymbol}
                          Colors.white),
                      if (val.data['forThisYear']['discountAmount'] > 0)
                        _listTile(
                            'discount'.tr,
                            "${formatter.format(val.data['forThisYear']['discountAmount'])} ${val.data['forThisYear']['currencySymbol']}", //${val.currency}
                            Colors.red.withOpacity(0.2)),
                      _listTile(
                          'amoA'.tr,
                          "${formatter.format(val.data['forThisYear']['paymentAmount'])} ${val.data['forThisYear']['currencySymbol']}", //${val.currency}
                          Colors.green.withOpacity(0.2)),
                      const Divider(
                        color: Colors.black,
                      ),
                      _listTile(
                          'rem'.tr,
                          "${formatter.format(val.data['forThisYear']['remaining'])} ${val.data['forThisYear']['currencySymbol']}",
                          Colors.white.withOpacity(0.1)),
                      _listTile(
                          'totRem'.tr,
                          "${formatter.format(val.data['forAllYears']['remaining'])} ${val.data['forAllYears']['currencySymbol']}",
                          Colors.white.withOpacity(0.1)),
                      // _listTile(
                      //     "المبلغ المتبقي الكلي",
                      //     "${formatter.format(val.allSalary)} ${val.currency}",
                      //     Colors.white.withOpacity(0.1)),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Get.to(() => const StudentSalaryDetails()),
                        child: Text(
                          "details".tr,
                          style: const TextStyle(
                              color: MyColor.purple,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Text(
                            "note".tr,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      val.data['forThisYear']['remaining'] <= 0
                          ? Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Text('noDep'.tr)),
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'nextIns'.tr,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 15),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: val.data['forThisYear']
                                                ["next_payment"],
                                            style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 15),
                                          )
                                        ]),
                                  )),
                            ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
      }),
    );
  }
}

//StudentSalaryAPI
_listTile(String title, String money, Color color) {
  return Container(
    color: color,
    child: ListTile(
      title: Text(
        title,
        style:
            const TextStyle(color: MyColor.black, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        money,
        style: const TextStyle(
            color: MyColor.purple, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
