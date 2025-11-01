import 'package:BBInaseem/provider/auth_provider.dart';
import 'package:BBInaseem/screens/shared/action_payment_button.dart';
import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../api_connection/student/api_salary.dart';
import '../../../../provider/student/provider_salary.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_loading.dart';

class StudentSalary extends StatefulWidget {
  const StudentSalary({super.key});

  @override
  State<StudentSalary> createState() => _StudentSalaryState();
}

class _StudentSalaryState extends State<StudentSalary> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EasyLoading.dismiss();
  }

  final StudentSalaryProvider salaryProvider =
      Get.find<StudentSalaryProvider>();
  _getData() async {
    final year =
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
      appBar: myAppBar("الاقساط"),
      body: Obx(() {
        return salaryProvider.isLoading.value
            ? loading()
            : salaryProvider.salaryData.isEmpty
                ? EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_1,
                    title: 'لاتوجد بيانات',
                    subTitle: 'لم يتم اضافة اقساط',
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
                : ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _listTile(
                                //
                                "اقساط السنة الكلية",
                                "${formatter.format(salaryProvider.salaryData['forThisYear']['salaryAmount'])} ${salaryProvider.salaryData['forThisYear']['currencySymbol']}", //${val.currencySymbol}
                                Colors.transparent),
                            if (salaryProvider.salaryData['forThisYear']
                                    ['discountAmount'] >
                                0)
                              _listTile(
                                  "الخصم",
                                  "${formatter.format(salaryProvider.salaryData['forThisYear']['discountAmount'])} ${salaryProvider.salaryData['forThisYear']['currencySymbol']}", //${val.currency}
                                  Colors.red.withOpacity(0.2)),
                            _listTile(
                                "الواصل",
                                "${formatter.format(salaryProvider.salaryData['forThisYear']['paymentAmount'])} ${salaryProvider.salaryData['forThisYear']['currencySymbol']}", //${val.currency}
                                Colors.green.withOpacity(0.2)),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16).copyWith(top: 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            _listTile(
                                "المبلغ المتبقي",
                                "${formatter.format(salaryProvider.salaryData['forThisYear']['remaining'])} ${salaryProvider.salaryData['forThisYear']['currencySymbol']}",
                                Colors.transparent),
                            const Divider(),
                            _listTile(
                                "المبلغ المتبقي الكلي",
                                "${formatter.format(salaryProvider.salaryData['forAllYears']['remaining'])} ${salaryProvider.salaryData['forAllYears']['currencySymbol']}",
                                Colors.transparent),
                          ],
                        ),
                      ),
                      PaymentActionButton(
                          salaryId: salaryProvider.salaryData['forThisYear']
                              ['_id'],
                          remining: salaryProvider.salaryData['forThisYear']
                              ['remaining']),
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8, left: 8),
                          child: Text(
                            "ملاحظة",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      salaryProvider.salaryData['forThisYear']['remaining'] <= 0
                          ? const Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 15, left: 15),
                                  child: Text("لايوجد ديون مترتبة لهذه السنة")),
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: RichText(
                                    text: TextSpan(
                                        text: 'القسط القادم في تاريخ ',
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 15),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: salaryProvider
                                                    .salaryData['forThisYear']
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
                      ),
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

// leleanAhmed405@jasmine-s.com
// fsazby
