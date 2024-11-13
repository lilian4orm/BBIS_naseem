import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:get/get.dart';

import '../../../api_connection/student/api_food_schedule.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/food_schedule_provider.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';

class FoodSchedule extends StatefulWidget {
  const FoodSchedule({super.key});

  @override
  FoodScheduleState createState() => FoodScheduleState();
}

///Food
class FoodScheduleState extends State<FoodSchedule> {
  final String _classId = Get.put(MainDataGetProvider()).mainData['account']
      ['account_division_current']['_id'];
  late SwiperController _controller;
  getData() {
    FoodScheduleAPI().getSchedule(_classId);
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
      appBar: myAppBar("Food Schedule"),
      body: GetBuilder<FoodScheduleProvider>(builder: (val) {
        return val.isLoading
            ? loading()
            : val.data.isEmpty
                ? EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_1,
                    title: 'No Schedule',
                    subTitle: 'No schedule available for this class',
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
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
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
                                          val.data[index]
                                              ['schedule_weekly_teacher_1']),
                                    if (val.data[index]
                                            ['schedule_weekly_lecture_2'] !=
                                        null)
                                      _showContainer(
                                          val.data[index]
                                              ['schedule_weekly_lecture_2'],
                                          val.data[index]
                                              ['schedule_weekly_teacher_2']),
                                    if (val.data[index]
                                            ['schedule_weekly_lecture_3'] !=
                                        null)
                                      _showContainer(
                                          val.data[index]
                                              ['schedule_weekly_lecture_3'],
                                          val.data[index]
                                              ['schedule_weekly_teacher_3']),
                                    if (val.data[index]
                                            ['schedule_weekly_lecture_4'] !=
                                        null)
                                      _showContainer(
                                          val.data[index]
                                              ['schedule_weekly_lecture_4'],
                                          val.data[index]
                                              ['schedule_weekly_teacher_4']),
                                    if (val.data[index]
                                            ['schedule_weekly_lecture_5'] !=
                                        null)
                                      _showContainer(
                                          val.data[index]
                                              ['schedule_weekly_lecture_5'],
                                          val.data[index]
                                              ['schedule_weekly_teacher_5']),
                                    if (val.data[index]
                                            ['schedule_weekly_lecture_6'] !=
                                        null)
                                      _showContainer(
                                          val.data[index]
                                              ['schedule_weekly_lecture_6'],
                                          val.data[index]
                                              ['schedule_weekly_teacher_6']),
                                    if (val.data[index]
                                            ['schedule_weekly_lecture_7'] !=
                                        null)
                                      _showContainer(
                                          val.data[index]
                                              ['schedule_weekly_lecture_7'],
                                          val.data[index]
                                              ['schedule_weekly_teacher_7']),
                                    if (val.data[index]
                                            ['schedule_weekly_lecture_8'] !=
                                        null)
                                      _showContainer(
                                          val.data[index]
                                              ['schedule_weekly_lecture_8'],
                                          val.data[index]
                                              ['schedule_weekly_teacher_8']),
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
