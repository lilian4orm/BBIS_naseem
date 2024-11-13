import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:BBInaseem/api_connection/auth_connection.dart';

import '../../../../../api_connection/student/api_ride.dart';
import '../../../../../provider/auth_provider.dart';
import '../../../../../provider/student/provider_ride.dart';
import '../../../../../static_files/my_color.dart';
import '../../../../../static_files/my_times.dart';
import 'student_map.dart';

class StudentDriver extends StatefulWidget {
  final Map userData;
  const StudentDriver({super.key, required this.userData});

  @override
  _StudentDriverState createState() => _StudentDriverState();
}

class _StudentDriverState extends State<StudentDriver> {
  //final String _date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  String? _date;
  showData() {
    Map date = {"date": _date};
    StudentRideAPI().getRides(date);
  }

  @override
  void initState() {
    Auth().getStudentInfo();
    showData();
    super.initState();
  }

  DateTime selectedDate = DateTime.now();
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now().add(const Duration(days: -365)),
        locale: const Locale("en", "US"),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      _date = formattedDate;
      showData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        title: Text(
          "GPS".tr,
          style: const TextStyle(color: MyColor.purple),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: MyColor.purple,
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _selectBirthday(context);
            },
            icon: const Icon(LineIcons.calendarWithDayFocus),
          )
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          GetBuilder<MainDataGetProvider>(builder: (val) {
            return //val.mainData == null
                Center(
              child: Container(
                constraints: const BoxConstraints(
                    minWidth: 100,
                    maxWidth: 200,
                    minHeight: 100,
                    maxHeight: 200),
                width: Get.height / 6,
                height: Get.height / 6,
                decoration: BoxDecoration(
                    border: Border.all(width: 1.5, color: MyColor.purple),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    shape: BoxShape.rectangle),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Image.asset("assets/img/graduated.png"),
                ),
              ),
            );
            // : val.mainData['account']['account_img'] == null
            //     ? Center(
            //         child: Container(
            //           constraints: const BoxConstraints(
            //               minWidth: 100,
            //               maxWidth: 200,
            //               minHeight: 100,
            //               maxHeight: 200),
            //           width: Get.height / 6,
            //           height: Get.height / 6,
            //           decoration: BoxDecoration(
            //               border:
            //                   Border.all(width: 1.5, color: MyColor.purple),
            //               borderRadius:
            //                   const BorderRadius.all(Radius.circular(10.0)),
            //               shape: BoxShape.rectangle),
            //           child: ClipRRect(
            //             borderRadius:
            //                 const BorderRadius.all(Radius.circular(10.0)),
            //             child: Image.asset("assets/img/graduated.png"),
            //           ),
            //         ),
            //       )
            //     : Center(
            //         child: Container(
            //           width: Get.height / 6,
            //           height: Get.height / 6,
            //           decoration: BoxDecoration(
            //               border:
            //                   Border.all(width: 1.5, color: MyColor.purple),
            //               borderRadius:
            //                   const BorderRadius.all(Radius.circular(10.0)),
            //               shape: BoxShape.rectangle),
            //           child: ClipRRect(
            //             borderRadius:
            //                 const BorderRadius.all(Radius.circular(10.0)),
            //             child: CachedNetworkImage(
            //               imageUrl: val.contentUrl +
            //                   val.mainData['account']['account_img'],
            //               fit: BoxFit.cover,
            //               placeholder: (context, url) =>
            //                   const CircularProgressIndicator(),
            //               errorWidget: (context, url, error) =>
            //                   const Icon(Icons.error),
            //             ),
            //           ),
            //         ),
            //       );
          }),
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  "student".tr,
                  maxLines: 1,
                  minFontSize: 15,
                  maxFontSize: 20,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColor.black),
                ),
                AutoSizeText(
                  widget.userData['account_name'].toString(),
                  maxLines: 1,
                  minFontSize: 15,
                  maxFontSize: 20,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColor.purple),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          GetBuilder<StudentRideProvider>(builder: (val) {
            return Column(
              children: [
                val.data
                            .where((element) =>
                                element['driver_student_ride_status'] ==
                                "PickupFromHome")
                            .length ==
                        1
                    ? _listTile(
                        'inCar'.tr,
                        true,
                        toTimeOnly(
                            val.data
                                .where((element) =>
                                    element['driver_student_ride_status'] ==
                                    "PickupFromHome")
                                .toList()[0]['created_at'],
                            12))
                    : _listTile('inCar'.tr, false, null),
                val.data
                            .where((element) =>
                                element['driver_student_ride_status'] ==
                                "GettingSchool")
                            .length ==
                        1
                    ? _listTile(
                        'schAri'.tr,
                        true,
                        toTimeOnly(
                            val.data
                                .where((element) =>
                                    element['driver_student_ride_status'] ==
                                    "GettingSchool")
                                .toList()[0]['created_at'],
                            12))
                    : _listTile('schAri'.tr, false, null),
                val.data
                            .where((element) =>
                                element['driver_student_ride_status'] ==
                                "PickupFromSchool")
                            .length ==
                        1
                    ? _listTile(
                        'schLef'.tr,
                        true,
                        toTimeOnly(
                            val.data
                                .where((element) =>
                                    element['driver_student_ride_status'] ==
                                    "PickupFromSchool")
                                .toList()[0]['created_at'],
                            12))
                    : _listTile('schLef'.tr, false, null),
                val.data
                            .where((element) =>
                                element['driver_student_ride_status'] ==
                                "GettingHome")
                            .length ==
                        1
                    ? _listTile(
                        'homRe'.tr,
                        true,
                        toTimeOnly(
                            val.data
                                .where((element) =>
                                    element['driver_student_ride_status'] ==
                                    "GettingHome")
                                .toList()[0]['created_at'],
                            12))
                    : _listTile('homRe'.tr, false, null),
              ],
            );
          }),
          const SizedBox(
            height: 20,
          ),
          GetBuilder<MainDataGetProvider>(builder: (val) {
            return Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: MyColor.purple),
              child: TextButton(
                onPressed: () {
                  // todo gps doing
                  val.mainData['account']["account_driver"] == null
                      ? Get.snackbar("note".tr, 'noWit'.tr,
                          colorText: Colors.white,
                          backgroundColor: Colors.orange)
                      : val.mainData['account']['school']['school_features']
                              ['features_gps']
                          ? Get.to(() => const StudentsMap())
                          : Get.snackbar("note".tr, 'feaNot'.tr,
                              colorText: Colors.white,
                              backgroundColor: Colors.orange);
                  //_mainDataGetProvider.mainData['account']["account_driver"]
                },
                child: const Text(
                  "GPS",
                  style: TextStyle(
                      color: MyColor.white0, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          Center(
              child: Text(
            'follow'.tr,
            style: const TextStyle(color: MyColor.purple),
          ))
        ],
      ),
    );
  }

  _listTile(title, value, date) {
    return Theme(
      data: ThemeData(
          unselectedWidgetColor: MyColor.purple,
          primarySwatch: MyColor().yellowMaterial),
      child: CheckboxListTile(
        title: Text(
          title,
          style: const TextStyle(
              color: MyColor.purple, fontWeight: FontWeight.bold),
        ),
        selected: false,
        onChanged: (_) {},
        value: value,
        secondary: date == null
            ? null
            : Text(
                date.toString(),
                style: const TextStyle(color: MyColor.purple),
              ),
        controlAffinity: ListTileControlAffinity.leading,
        checkColor: MyColor.purple,
      ),
    );
  }
}
