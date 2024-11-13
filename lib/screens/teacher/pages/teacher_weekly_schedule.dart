import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:get/get.dart';

import '../../../api_connection/teacher/api_weekly_schedule.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/teacher/provider_weekly_schedule.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';

class TeacherWeeklySchedule extends StatefulWidget {
  const TeacherWeeklySchedule({Key? key}) : super(key: key);

  @override
  _TeacherWeeklyScheduleState createState() => _TeacherWeeklyScheduleState();
}

class _TeacherWeeklyScheduleState extends State<TeacherWeeklySchedule> {
  final List _classId =
      Get.put(MainDataGetProvider()).mainData['account']['account_division'];
  String _classes = '';
  List<S2Choice<String>> classes = [];
  late SwiperController _controller;
  getData(String classId) {
    WeeklyScheduleAPI().getSchedule(classId);
  }

  @override
  void initState() {
    _controller = SwiperController();
    for (var _data in _classId) {
      classes.add(
        S2Choice<String>(
          value: _data['_id'].toString(),
          title: "${_data['class_name']} - ${_data['leader']}",
          group: _data['class_name'].toString(),
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar("weeklyTable".tr),
      body: Column(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(
                  minWidth: 200, maxWidth: 350, maxHeight: 73),
              margin: const EdgeInsets.only(
                  top: 10, bottom: 10, right: 10, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: MyColor.purple,
                ),
                color: MyColor.white1.withOpacity(.5),
              ),
              child: SmartSelect<String>.single(
                title: "claty".tr,
                placeholder: 'pick'.tr,
                selectedValue: _classes,
                onChange: (selected) {
                  setState(() => _classes = selected.value);
                  getData(selected.value);
                },
                choiceItems: classes,
                choiceGrouped: true,
                modalFilter: true,
                modalFilterAuto: true,
              ),
            ),
          ),
          Expanded(
            child: _classes == ""
                ? Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: EmptyWidget(
                      image: null,
                      packageImage: PackageImage.Image_3,
                      title: 'attenstion'.tr,
                      subTitle: 'mclaty'.tr,
                      titleTextStyle: const TextStyle(
                        fontSize: 22,
                        color: Color(0xff9da9c7),
                        fontWeight: FontWeight.w500,
                      ),
                      subtitleTextStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xffabb8d6),
                      ),
                    ),
                  )
                : GetBuilder<TeacherWeeklyScheduleProvider>(builder: (val) {
                    return val.isLoading
                        ? loading()
                        : val.data.isEmpty
                            ? EmptyWidget(
                                image: null,
                                packageImage: PackageImage.Image_1,
                                title: "NO Data".tr,
                                subTitle: 'noSchAdd'.tr,
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _controller.previous(animation: true);
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: MyColor.purple,
                                        ),
                                      ),
                                      Text(
                                        val.data[val.indexTable]
                                            ['schedule_weekly_day'],
                                        //_data.keys.toList()
                                        style: const TextStyle(
                                            color: MyColor.purple,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _controller.next(animation: true);
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: MyColor.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Swiper(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                            padding: const EdgeInsets.all(20),
                                            child: ListView(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              children: [
                                                if (val.data[index]['schedule_weekly_lecture_1'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_1'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_1']),
                                                if (val.data[index]['schedule_weekly_lecture_2'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_2'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_2']),
                                                if (val.data[index]['schedule_weekly_lecture_3'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_3'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_3']),
                                                if (val.data[index]['schedule_weekly_lecture_4'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_4'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_4']),
                                                if (val.data[index]['schedule_weekly_lecture_5'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_5'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_5']),
                                                if (val.data[index]['schedule_weekly_lecture_6'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_6'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_6']),
                                                if (val.data[index]['schedule_weekly_lecture_7'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_7'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_7']),
                                                if (val.data[index]['schedule_weekly_lecture_8'] !=
                                                    null)
                                                  _showContainer(
                                                      val.data[index][
                                                          'schedule_weekly_lecture_8'],
                                                      val.data[index][
                                                          'schedule_weekly_teacher_8']),
                                              ],
                                            ));
                                      },
                                      onIndexChanged: (int index) {
                                        val.changeIndexTable(index);
                                      },
                                      itemCount: val.data.length,
                                      controller: _controller,
                                    ),
                                  ),
                                ],
                              );
                  }),
          ),
        ],
      ),
    );
  }

  _showContainer(subject, teacher) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1.0, color: MyColor.purple),
      ),
      child: ListTile(
        title: Text(
          subject,
          style: const TextStyle(
              color: MyColor.purple, fontWeight: FontWeight.bold),
        ),
        subtitle: teacher == null
            ? null
            : Text(
                teacher,
                style: const TextStyle(
                  color: MyColor.grayDark,
                ),
              ),
      ),
    );
  }
}