import 'package:card_swiper/card_swiper.dart';
import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api_connection/student/api_degree.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/provider_degree.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';

class ExamDegree extends StatefulWidget {
  const ExamDegree({super.key});

  @override
  _ExamDegreeState createState() => _ExamDegreeState();
}

class _ExamDegreeState extends State<ExamDegree> {
  late SwiperController _controller;
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  @override
  void initState() {
    _controller = SwiperController();
    Map data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "class_school": _mainDataGetProvider.mainData['account']
          ['account_division_current']['_id'],
    };
    DegreeStudentAPI().getExamsDegree(data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('geades'.tr),
      body: GetBuilder<DegreeProvider>(builder: (val) {
        return Container(
          child: val.isLoading
              ? loading()
              : val.data.isEmpty
                  ? EmptyWidget(
                      image: null,
                      packageImage: PackageImage.Image_3,
                      title: 'noDeg'.tr,
                      subTitle: 'noDataAd'.tr,
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
                              val.data[val.index]['degree_exam_name'],
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 1.0, color: MyColor.purple),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10)),
                                              color: MyColor.purple
                                                  .withOpacity(.3)),
                                          child: ListTile(
                                            title: Text(
                                              "subject".tr,
                                              style: const TextStyle(
                                                  color: MyColor.purple,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            trailing: Text(
                                              'grdTot'.tr,
                                              style: const TextStyle(
                                                  color: MyColor.purple,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              //_data[val.indexTable]['exams_name'],
                                              itemCount: val
                                                  .data[index]["data"].length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int indexes) {
                                                return ListTile(
                                                  title: Text(
                                                    val.data[index]['data']
                                                            [indexes]['subject']
                                                        ['subject_name'],
                                                    style: const TextStyle(
                                                        color: MyColor.purple,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: Text(
                                                    val.data[index]['data']
                                                                    [indexes]
                                                                ['students'] ==
                                                            null
                                                        ? "${val.data[index]['data'][indexes]['degree_max']}/--"
                                                        : "${val.data[index]['data'][indexes]['students']['degree']}/${val.data[index]['data'][indexes]['degree_max']}",
                                                    style: TextStyle(
                                                        color: val.data[index]
                                                                            ['data']
                                                                        [indexes][
                                                                    'students'] ==
                                                                null
                                                            ? MyColor.purple
                                                            : val.data[index]['data']
                                                                            [indexes]['students']
                                                                        [
                                                                        'degree'] <
                                                                    (val.data[index]['data'][indexes]
                                                                            ['degree_max'] /
                                                                        2)
                                                                ? MyColor.red
                                                                : MyColor.purple,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                );
                                              }),
                                        )
                                      ],
                                    ),
                                  ));
                            },
                            onIndexChanged: (int index) {
                              val.changeIndex(index);
                            },
                            itemCount: val.data.length,
                            controller: _controller,
                          ),
                        ),
                      ],
                    ),
        );
      }),
    );
  }
}
