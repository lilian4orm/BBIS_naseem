import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:get/get.dart';

import '../../../api_connection/teacher/api_degree_teacher.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/teacher/provider_degree_teacher.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';

class TeacherExamSchedule extends StatefulWidget {
  const TeacherExamSchedule({Key? key}) : super(key: key);

  @override
  _TeacherExamScheduleState createState() => _TeacherExamScheduleState();
}

class _TeacherExamScheduleState extends State<TeacherExamSchedule> {
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  final List _classId =
      Get.put(MainDataGetProvider()).mainData['account']['account_division'];
  String? _classes = '';
  List<S2Choice<String>> classes = [];
  getData(classes) {
    Map data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "class_school": classes,
    };
    ExamTeacherAPI().getExamsSchedule(data);
  }

  @override
  void initState() {
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
      appBar: myAppBar('weeklyTable'.tr),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
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
                  color: MyColor.white1,
                ),
                child: SmartSelect<String>.single(
                  title: 'claty'.tr,
                  placeholder: 'pick'.tr,
                  selectedValue: _classes!,
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
              child: _classes!.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(right: 50, left: 50),
                      child: EmptyWidget(
                        image: null,
                        packageImage: PackageImage.Image_4,
                        title: 'claty'.tr,
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
                  : GetBuilder<ExamsTeacherProvider>(builder: (val) {
                      return val.isLoading
                          ? loading()
                          : val.data.isEmpty
                              ? EmptyWidget(
                                  image: null,
                                  packageImage: PackageImage.Image_1,
                                  title: 'noSchedule'.tr,
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
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: val.data.length,
                                  itemBuilder:
                                      (BuildContext context, int indexes) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      decoration: BoxDecoration(
                                          color: MyColor.white3,
                                          border:
                                              Border.all(color: MyColor.purple),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: ExpansionTile(
                                        title: Text(
                                          val.data[indexes]['exams_name']
                                              .toString(),
                                          style: const TextStyle(
                                              color: MyColor.purple),
                                        ),
                                        children: _children(val.data[indexes]
                                            ['exams_schedule']),
                                      ),
                                    );
                                  });
                    }),
            ),
          ],
        ),
      ),
    );
  }

  _children(List res) {
    List<Widget> widget = [
      Container(
        padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
        color: MyColor.white0,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'today'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: MyColor.purple),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'date'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: MyColor.purple),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'subject'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: MyColor.purple),
              ),
            ),
          ],
        ),
      )
    ];
    for (var _d in res) {
      widget.add(Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          color: MyColor.white0,
        ),
        padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                _d['schedule_exams_day'].toString(),
                style: const TextStyle(color: MyColor.purple),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                _d['schedule_exams_date'].toString(),
                style: const TextStyle(color: MyColor.purple),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _d['schedule_exams_subject'].toString(),
                style: const TextStyle(color: MyColor.purple),
              ),
            ),
          ],
        ),
      ));
    }
    return widget;
  }
}
