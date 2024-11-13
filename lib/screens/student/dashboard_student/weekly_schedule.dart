import 'package:card_swiper/card_swiper.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api_connection/student/api_weekly_schedule.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/weekly_schedule_provider.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';

class WeeklySchedule extends StatefulWidget {
  const WeeklySchedule({super.key});

  @override
  WeeklyScheduleState createState() => WeeklyScheduleState();
}

class WeeklyScheduleState extends State<WeeklySchedule> {
  final String _classId = Get.put(MainDataGetProvider()).mainData['account']
      ['account_division_current']['_id'];
  late SwiperController _controller;

  getData() {
    WeeklyScheduleAPI().getSchedule(_classId);
  }

  @override
  void initState() {
    _controller = SwiperController();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('weeklyTable'.tr),
      body: GetBuilder<WeeklyScheduleProvider>(builder: (val) {
        return val.isLoading
            ? loading()
            : val.data.isEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        EmptyWidget(
                          image: null,
                          packageImage: PackageImage.Image_1,
                          title: 'nodta'.tr,
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
                        ),
                        // Your other widgets here...
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            val.data[val.indexTable]['schedule_weekly_day'],
                            style: const TextStyle(
                              color: MyColor.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
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
                      // Your other widgets here...
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 170,
                        child: Swiper(
                          itemBuilder: (BuildContext context, int index) {
                            return _isLessonsFound(val.data[index])
                                ? Container(
                                    padding: const EdgeInsets.all(20),
                                    child: ListView(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      children: [
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_1'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_1'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_1']),
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_2'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_2'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_2']),
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_3'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_3'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_3']),
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_4'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_4'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_4']),
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_5'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_5'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_5']),
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_6'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_6'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_6']),
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_7'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_7'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_7']),
                                        if (val.data[index]
                                                ['schedule_weekly_lecture_8'] !=
                                            null)
                                          _showContainer(
                                              val.data[index]
                                                  ['schedule_weekly_lecture_8'],
                                              val.data[index][
                                                  'schedule_weekly_teacher_8']),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        // Your other widgets here...
                                        EmptyWidget(
                                          image: null,
                                          packageImage: PackageImage.Image_1,
                                          title: 'nodta'.tr,
                                          subTitle: 'noLesAdd'.tr,
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
                                        // Your other widgets here...
                                      ],
                                    ),
                                  );
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
    );
  }

  bool _isLessonsFound(dynamic day) {
    return day['schedule_weekly_lecture_1'] != null ||
        day['schedule_weekly_lecture_2'] != null ||
        day['schedule_weekly_lecture_3'] != null ||
        day['schedule_weekly_lecture_4'] != null ||
        day['schedule_weekly_lecture_5'] != null ||
        day['schedule_weekly_lecture_6'] != null ||
        day['schedule_weekly_lecture_7'] != null ||
        day['schedule_weekly_lecture_8'] != null;
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
            color: MyColor.purple,
            fontWeight: FontWeight.bold,
          ),
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
