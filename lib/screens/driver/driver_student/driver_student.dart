import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../api_connection/driver/api_rides_students.dart';
import '../../../provider/driver/provider_rides_students.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import '../../../static_files/my_times.dart';

class DriverStudent extends StatefulWidget {
  const DriverStudent({super.key});

  @override
  _DriverStudentState createState() => _DriverStudentState();
}

class _DriverStudentState extends State<DriverStudent> {
  bool checkBoxValue = false;

  _getData() {
    RidesStudentsAPI().getStudents();
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar("students".tr),
      body: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: MyColor.purple),
          borderRadius: const BorderRadius.all(
              Radius.circular(10.0) //                 <--- border radius here
              ),
        ),
        child: GetBuilder<RidesStudentsProvider>(builder: (val) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        'stuName'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: MyColor.purple),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 1.5,
                      color: MyColor.purple,
                      height: 60,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'inCar'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: MyColor.purple),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 1.5,
                      color: MyColor.purple,
                      height: 60,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'schAri'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: MyColor.purple),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 1.5,
                      color: MyColor.purple,
                      height: 60,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'schLef'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: MyColor.purple),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 1.5,
                      color: MyColor.purple,
                      height: 60,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'homRe'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: MyColor.purple),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 500,
                color: MyColor.purple,
                height: 1.5,
              ),
              Expanded(
                child: val.isLoading
                    ? loading()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: val.data.length,
                        itemBuilder: (BuildContext context, int indexes) {
                          return Row(
                            children: [
                              ///account_name
                              Expanded(
                                flex: 3,
                                child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 10, left: 10),
                                    child: Text(
                                      val.data[indexes]['account_name'],
                                      style: const TextStyle(
                                          fontSize: 12, color: MyColor.purple),
                                    )),
                              ),
                              _expanded(val.data[indexes]['status'],
                                  "PickupFromHome", val.data[indexes]['_id']),
                              _expanded(val.data[indexes]['status'],
                                  "GettingSchool", val.data[indexes]['_id']),
                              _expanded(val.data[indexes]['status'],
                                  "PickupFromSchool", val.data[indexes]['_id']),
                              _expanded(val.data[indexes]['status'],
                                  "GettingHome", val.data[indexes]['_id']),
                            ],
                          );
                        }),
              )
            ],
          );
        }),
      ),
    );
  }
}

Expanded _expanded(List data, String type, String studentId) {
  return Expanded(
    flex: 1,
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            activeColor: const Color(0xff22b573),
            value: data
                .where(
                    (element) => element['driver_student_ride_status'] == type)
                .toList()
                .isNotEmpty,
            onChanged: (bool? value) {
              if (data
                  .where((element) =>
                      element['driver_student_ride_status'] == type)
                  .toList()
                  .isEmpty) {
                _addStatusStudent(studentId, type);
              }
            },
          ),
          data
                  .where((element) =>
                      element['driver_student_ride_status'] == type)
                  .toList()
                  .isEmpty
              ? const AutoSizeText(
                  "",
                  maxLines: 1,
                  minFontSize: 11,
                  style: TextStyle(fontSize: 11),
                )
              : AutoSizeText(
                  toTimeOnly(
                      data
                          .where((element) =>
                              element['driver_student_ride_status'] == type)
                          .toList()[0]['created_at'],
                      24),
                  maxLines: 1,
                  minFontSize: 11,
                  style: const TextStyle(fontSize: 11, color: Colors.black))
        ],
      ),
    ),
  );
}

_addStatusStudent(String studentId, String type) async {
  EasyLoading.show(status: 'plsWit'.tr, dismissOnTap: true);
  RidesStudentsAPI().addStudentStatus(studentId, type);
}
