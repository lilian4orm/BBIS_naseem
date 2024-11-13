import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:get/get.dart';

import '../../../../api_connection/teacher/api_degree_teacher.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';
import 'degree_student_list.dart';

class DegreeChoice extends StatefulWidget {
  const DegreeChoice({Key? key}) : super(key: key);

  @override
  State<DegreeChoice> createState() => _DegreeChoiceState();
}

class _DegreeChoiceState extends State<DegreeChoice> {
  final MainDataGetProvider _mainDataProvider = Get.put(MainDataGetProvider());
  String _notificationSubject = '';
  String _examSubject = '';
  String _classSchool = '';
  List<S2Choice<String>> notificationSubject = [];
  List<S2Choice<String>> examSubject = [];
  List<S2Choice<String>> classSchool = [];

  Future<void> _showNotificationSubject() async {
    if (_mainDataProvider.mainData['account']['account_subject'] != null) {
      for (Map subject in _mainDataProvider.mainData['account']
          ['account_subject']) {
        notificationSubject.add(S2Choice<String>(
          value: subject['_id'],
          title: subject['subject_name'],
        ));
      }
    }
  }

  Future<void> _examsList(String subjectId) async {
    EasyLoading.show(status: 'getData'.tr);
    final res = await DegreeTeacherAPI().getExamsDegree(
      subjectId,
      _mainDataProvider.mainData['setting'][0]['setting_year'],
    );

    if (!res['error']) {
      for (Map examSubjectMap in res['results']) {
        examSubject.add(S2Choice<String>(
          value: examSubjectMap['degree_exam_name'],
          title: examSubjectMap['degree_exam_name'],
        ));
      }
    }
  }

  Future<void> _classSchoolList(String examName) async {
    EasyLoading.show(status: 'getData'.tr);
    final data = {
      "exam_name": examName,
      "study_year": _mainDataProvider.mainData['setting'][0]['setting_year'],
    };
    final res = await DegreeTeacherAPI().getSchoolDegree(data);

    if (!res['error']) {
      for (Map examSubjectMap in res['results']) {
        classSchool.add(S2Choice<String>(
          value: examSubjectMap['class_school']['_id'],
          title:
              "${examSubjectMap['class_school']['class_name']} - ${examSubjectMap['class_school']['leader']}",
        ));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _showNotificationSubject();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar("degrees".tr),
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: MyColor.purple,
                ),
                color: MyColor.white1,
              ),
              child: SmartSelect<String>.single(
                title: "subject".tr,
                placeholder: 'pick'.tr,
                selectedValue: _notificationSubject,
                choiceItems: notificationSubject,
                onChange: (selected) async {
                  setState(() {
                    _notificationSubject = selected.value;
                    _examSubject = '';
                    _classSchool = '';
                    examSubject.clear();
                    classSchool.clear();
                  });
                  await _examsList(selected.value);
                },
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: MyColor.purple,
                ),
                color: MyColor.white1,
              ),
              child: SmartSelect<String>.single(
                title: "exam".tr,
                placeholder: 'pick'.tr,
                selectedValue: _examSubject,
                choiceItems: examSubject,
                onChange: (selected) async {
                  setState(() {
                    _examSubject = selected.value;
                    _classSchool = '';
                    classSchool.clear();
                  });
                  await _classSchoolList(selected.value);
                },
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: MyColor.purple,
                ),
                color: MyColor.white1,
              ),
              child: SmartSelect<String>.single(
                title: "claty".tr,
                placeholder: 'pick'.tr,
                selectedValue: _classSchool,
                choiceItems: classSchool,
                onChange: (selected) {
                  setState(() {
                    _classSchool = selected.value;
                  });
                },
              ),
            ),
          ),
          MaterialButton(
            onPressed: (_examSubject.isNotEmpty && _classSchool.isNotEmpty)
                ? () async {
                    final data = {
                      "exam_name": _examSubject,
                      "study_year": _mainDataProvider.mainData['setting'][0]
                          ['setting_year'],
                      "class_school": _classSchool,
                      "subject_id": _notificationSubject,
                    };
                    EasyLoading.show(status: "جار جلب البيانات");
                    final res =
                        await DegreeTeacherAPI().getStudentListDegrees(data);
                    Get.to(() => DegreeStudentList(
                          degreeData: res,
                        ));
                  }
                : null,
            color: MyColor.purple,
            textColor: MyColor.yellow,
            child: Text("show".tr),
          )
        ],
      ),
    );
  }
}
