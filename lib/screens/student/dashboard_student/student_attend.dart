import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:line_icons/line_icons.dart';

import '../../../api_connection/student/api_attend.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/attend_provider.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';

class StudentAttend extends StatefulWidget {
  final Map userData;
  const StudentAttend({super.key, required this.userData});

  @override
  _StudentAttendState createState() => _StudentAttendState();
}

class _StudentAttendState extends State<StudentAttend> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _search = TextEditingController();
  DateTime selectedDateBirthday = DateTime.now();
  String? firstDate;
  String? secondDate;
  int page = 0;

  Future<void> _selectRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale("en", "US"),
      firstDate: DateTime.now().add(const Duration(days: -365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDateFirst =
          intl.DateFormat('yyyy-MM-dd').format(picked.start);
      final formattedDateSecond =
          intl.DateFormat('yyyy-MM-dd').format(picked.end);
      firstDate = formattedDateFirst;
      secondDate = formattedDateSecond;
      _search.text =
          "${'from'.tr} $formattedDateFirst ${'to'.tr} $formattedDateSecond";
      Get.put(StudentAttendProvider()).destroyData();
      _getData();
    }
  }

  _getData() {
    Map data = {
      "study_year": Get.put(MainDataGetProvider()).mainData['setting'][0]
          ['setting_year'],
      "page": page,
      "firstDate": firstDate,
      "secondDate": secondDate,
    };
    AttendAPI().getAttend(data);
  }

  @override
  void initState() {
    _getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++;
        _getData();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    Get.put(StudentAttendProvider()).changeLoading(true);
    Get.put(StudentAttendProvider()).destroyData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('com'.tr),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: TextFormField(
              maxLines: 1,
              autofocus: false,
              controller: _search,
              cursorRadius: const Radius.circular(16.0),
              cursorWidth: 2.0,
              textInputAction: TextInputAction.done,
              minLines: 1,
              onTap: () {
                _selectRange(context);
              },
              enableInteractiveSelection: true,
              readOnly: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                  labelText: 'seDate'.tr,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 10),
                  fillColor: MyColor.white4,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
                      color: MyColor.black,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: MyColor.white4,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: MyColor.white4,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: MyColor.red,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      LineIcons.search,
                    ),
                  ),
                  filled: true
                  //fillColor: Colors.green
                  ),
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.only(top: 5, bottom: 5),
          //   child: GetBuilder<StudentAttendProvider>(builder: (val) {
          //     return Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         widgetCount("عدد المحاضرات", val.allPresence),
          //         widgetCount("العدد الحالي", val.forThisMonth),
          //       ],
          //     );
          //   }),
          // ),
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: GetBuilder<StudentAttendProvider>(builder: (val) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  widgetCount('Present', val.allVacation),
                  widgetCount("Authorised absence", val.allAbsence),
                  widgetCount("Unauthorised absence", val.allPresence),
                ],
              );
            }),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
              margin: const EdgeInsets.only(top: 10),
              child: GetBuilder<StudentAttendProvider>(
                builder: (val) => val.isLoading
                    ? loading()
                    : val.userList.isEmpty
                        ? EmptyWidget(
                            image: null,
                            packageImage: PackageImage.Image_1,
                            title: 'nodta'.tr,
                            subTitle: "NO Data".tr,
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
                            controller: _scrollController,
                            itemCount: val.userList.length,
                            itemBuilder: (BuildContext context, int indexes) {
                              return listTileData(
                                  val.userList[indexes]['absence_type'],
                                  val.userList[indexes]['absence_date']
                                      .toString());
                            }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget listTileData(String absenceType, String date) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
        color: _color(absenceType).withOpacity(0.25),
        borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      title: Text(
        date.toString(),
        style:
            const TextStyle(color: MyColor.purple, fontWeight: FontWeight.bold),
      ),
      trailing: _text(absenceType),
    ),
  );
}

Widget _text(String text) {
  if (text == "vacation") {
    return Text(
      "vocation".tr,
      style:
          const TextStyle(color: MyColor.purple, fontWeight: FontWeight.bold),
    );
  } else if (text == "absence") {
    return Text(
      "absent".tr,
      style:
          const TextStyle(color: MyColor.purple, fontWeight: FontWeight.bold),
    );
  } else {
    return Text(
      "com".tr,
      style:
          const TextStyle(color: MyColor.purple, fontWeight: FontWeight.bold),
    );
  }
}

Color _color(String text) {
  if (text == "vacation") {
    return MyColor.purple;
  } else if (text == "absence") {
    return MyColor.red;
  } else {
    return MyColor.green;
  }
}

Widget widgetCount(String title, int count) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
          border: Border.all(
            color: MyColor.purple,
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Container(
                padding: const EdgeInsets.all(3),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                )),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
                color: MyColor.purple, shape: BoxShape.circle),
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 11, color: MyColor.yellow),
            ),
          )
        ],
      ),
    ),
  );
}
