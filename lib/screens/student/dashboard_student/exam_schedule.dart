import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api_connection/student/api_degree.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/provider_degree.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';

class ExamSchedule extends StatefulWidget {
  const ExamSchedule({super.key});

  @override
  _ExamScheduleState createState() => _ExamScheduleState();
}

class _ExamScheduleState extends State<ExamSchedule> {
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  @override
  void initState() {
    Map data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "class_school": _mainDataGetProvider.mainData['account']
          ['account_division_current']['_id'],
    };
    DegreeStudentAPI().getExamsSchedule(data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('examSch'.tr),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: GetBuilder<ExamsProvider>(builder: (val) {
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
                        color: MyColor.yellow,
                        fontWeight: FontWeight.w500,
                      ),
                      subtitleTextStyle: const TextStyle(
                        fontSize: 14,
                        color: MyColor.yellow,
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: val.data.length,
                      itemBuilder: (BuildContext context, int indexes) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                              color: MyColor.yellow.withOpacity(.2),
                              border: Border.all(color: MyColor.purple),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: ExpansionTile(
                            title: Text(
                              val.data[indexes]['exams_name'].toString(),
                              style: const TextStyle(color: MyColor.purple),
                            ),
                            children:
                                _children(val.data[indexes]['exams_schedule']),
                          ),
                        );
                      });
        }),
      ),
    );
  }

  _children(List res) {
    List<Widget> widget = [
      Container(
        padding: const EdgeInsets.only(right: 16, left: 8, top: 8, bottom: 8),
        color: MyColor.white0,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'today'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: MyColor.purple),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'date'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: MyColor.purple),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'subject'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: MyColor.purple),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'details'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: MyColor.purple),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      )
    ];
    for (var _d in res) {
      widget.add(GestureDetector(
        onTap: () {
          if (_d['schedule_exam_description'] != null) {
            Get.defaultDialog(
                title: 'examS'.tr,
                content: Text(_d['schedule_exam_description'].toString()));
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            color: MyColor.white0,
          ),
          padding:
              const EdgeInsets.only(right: 16, left: 8, top: 10, bottom: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _d['schedule_exams_day'].toString(),
                  style: const TextStyle(color: MyColor.purple, fontSize: 11),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  _d['schedule_exams_date'].toString(),
                  style: const TextStyle(color: MyColor.purple, fontSize: 11),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _d['schedule_exams_subject'].toString(),
                  style: const TextStyle(color: MyColor.purple, fontSize: 11),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Icon(
                  Icons.description,
                  size: 20,
                  color: MyColor.purple,
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return widget;
  }
}
