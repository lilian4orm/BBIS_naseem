//var a = Get.put(MainDataGetProvider()).mainData['setting'][0]['setting_year'];

import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../api_connection/teacher/api_salary.dart';
import '../../../../../provider/auth_provider.dart';
import '../../../../../provider/teacher/provider_salary.dart';
import '../../../../../static_files/my_appbar.dart';
import '../../../../../static_files/my_color.dart';
import '../../../../../static_files/my_loading.dart';
import 'teacher_salary_details.dart';

final formatter = NumberFormat.decimalPattern();

class TeacherSalary extends StatefulWidget {
  const TeacherSalary({super.key});

  @override
  State<TeacherSalary> createState() => _TeacherSalaryState();
}

class _TeacherSalaryState extends State<TeacherSalary> {
  _getData() {
    String year =
        Get.put(MainDataGetProvider()).mainData['setting'][0]['setting_year'];
    TeacherSalaryAPI().getSalary(year);
  }

  DateTime now = DateTime.now();
  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('salary'.tr),
      body: GetBuilder<TeacherSalaryProvider>(builder: (val) {
        return val.isLoading
            ? loading()
            : val.data.isEmpty
                ? EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_1,
                    title: 'nodta'.tr,
                    subTitle: 'nopaid'.tr,
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
                          'salaryType'.tr,
                          "${formatter.format(val.data['amount'])} ${val.data['currencySymbol']}",
                          Colors.white),
                      _listTile(
                          'deductions'.tr,
                          "${formatter.format(val.data['allDiscounts'])} ${val.data['currencySymbol']}",
                          Colors.red.withOpacity(0.2)),
                      _listTile(
                          "rewards".tr,
                          "${formatter.format(val.data['allAdditional'])} ${val.data['currencySymbol']}",
                          Colors.green.withOpacity(0.2)),
                      _listTile(
                          "lecture".tr,
                          "${formatter.format(val.data['allLectures'])} ${val.data['currencySymbol']}",
                          Colors.green.withOpacity(0.2)),
                      _listTile(
                          "observation".tr,
                          "${formatter.format(val.data['allWatch'])} ${val.data['currencySymbol']}",
                          Colors.green.withOpacity(0.2)),
                      const Divider(
                        color: Colors.black,
                      ),
                      _listTile(
                          'deserved amount'.tr,
                          "${formatter.format(val.data['pureMoney'])} ${val.data['currencySymbol']}",
                          Colors.white.withOpacity(0.1)),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Get.to(() => const TeacherSalaryDetails()),
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
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                            padding: const EdgeInsets.only(right: 15, left: 15),
                            child: RichText(
                              text: TextSpan(
                                  text: 'deliDate'.tr,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 11),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: val.data["payment_date"],
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 11),
                                    ),
                                  ]),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  );
      }),
    );
  }
}

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
