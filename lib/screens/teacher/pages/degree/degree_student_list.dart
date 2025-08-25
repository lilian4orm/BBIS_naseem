import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../api_connection/teacher/api_degree_teacher.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';

class DegreeStudentList extends StatefulWidget {
  final Map degreeData;
  const DegreeStudentList({super.key, required this.degreeData});

  @override
  State<DegreeStudentList> createState() => _DegreeStudentListState();
}

final _formCheck = GlobalKey<FormState>();

class _DegreeStudentListState extends State<DegreeStudentList> {
  final List<TextEditingController> _controller = [];
  @override
  void initState() {
    for (int i = 0; i < widget.degreeData['account_degree'].length; i++) {
      _controller.add(TextEditingController());
    }
    super.initState();
  }

//_formCheck.currentState!.validate()
  @override
  Widget build(BuildContext context) {
    //Logger().i(widget.degreeData);
    return Scaffold(
      appBar: myAppBar(widget.degreeData["degree_exam_name"] ?? ''),
      body: widget.degreeData['account_degree'].isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 50, left: 50),
                child: EmptyWidget(
                  image: null,
                  packageImage: PackageImage.Image_4,
                  title: 'الدرجات',
                  subTitle: 'لايوجد طلاب',
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
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formCheck,
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.degreeData['account_degree'].length,
                        itemBuilder: (BuildContext context, int indexes) {
                          return _content(
                              widget.degreeData['account_degree'][indexes],
                              _controller[indexes],
                              widget.degreeData['degree_max']);
                          //return listTileData(val.userList[indexes]['absence_type'], val.userList[indexes]['absence_date'].toString());
                        }),
                  ),
                ),
                MaterialButton(
                    color: MyColor.purple,
                    child: Text(
                      "add".tr,
                      style: const TextStyle(color: MyColor.yellow),
                    ),
                    onPressed: () {
                      if (_formCheck.currentState!.validate()) {
                        List students = [];
                        students.clear();
                        for (Map item in widget.degreeData["account_degree"]) {
                          String text = _controller[widget
                                  .degreeData["account_degree"]
                                  .indexOf(item)]
                              .text;
                          students.add({
                            "student_id": item['account_id'],
                            "degree": text.isNotEmpty
                                ? int.parse(text.removeAllWhitespace)
                                : null,
                          });
                        }
                        Map data = {
                          "id": widget.degreeData["_id"],
                          // "subject_id": widget.degreeData["subject_id"],
                          // "school_id": widget.degreeData["school_id"],
                          // "class_school": widget.degreeData["class_school"],
                          // "degree_exam_name": widget.degreeData["degree_exam_name"],
                          // "study_year": widget.degreeData["study_year"],
                          "students": students
                        };
                        //Logger().e(_data);
                        DegreeTeacherAPI().insertDegrees(data).then((result) {
                          showFlushbar(
                              context: context,
                              flushbar: Flushbar(
                                forwardAnimationCurve: Curves.decelerate,
                                reverseAnimationCurve: Curves.easeOut,
                                flushbarPosition: FlushbarPosition.TOP,
                                positionOffset: 20,
                                borderRadius: BorderRadius.circular(8),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                padding: const EdgeInsets.all(10),
                                message: 'Degree added successfully',
                                duration: const Duration(seconds: 3),
                                backgroundColor: Colors.green,
                              )..show(context));
                        });
                      }
                    })
              ],
            ),
    );
  }
}

Container _content(Map data, TextEditingController textEdit, int maxDegree) {
  if (data['account_degree'] != null) {
    textEdit.text = data['account_degree'].toString();
  }
  return Container(
    decoration: const BoxDecoration(color: MyColor.white0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(data["account_name"]),
        ),
        Container(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
          width: 100,
          child: TextFormField(
            controller: textEdit,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            style: const TextStyle(
              color: MyColor.black,
            ),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5),
                hintText: "الدرجة",
                errorStyle: const TextStyle(color: MyColor.grayDark),
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                    color: MyColor.black,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: MyColor.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(
                    color: MyColor.black,
                  ),
                ),
                filled: true
                //fillColor: Colors.green
                ),
            validator: (value) {
              if (value!.length > 3) {
                return "الرقم كبير";
              } else if (value.isNotEmpty) {
                if (int.parse(value.removeAllWhitespace) > maxDegree) {
                  return "الرقم كبير";
                } else {
                  return null;
                }
              } else {
                return null;
              }
            },
          ),
        ),
      ],
    ),
  );
}
