import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../../../../api_connection/teacher/api_notification.dart';
import '../../../../../provider/teacher/provider_notification.dart';
import '../../../../../static_files/my_appbar.dart';
import '../../../../../static_files/my_color.dart';
import '../../../../../static_files/my_image_grid.dart';
import '../../../../../static_files/my_times.dart';

class HomeworkStudentAnswerShow extends StatefulWidget {
  final Map data;
  final String contentUrl;
  const HomeworkStudentAnswerShow(
      {Key? key, required this.data, required this.contentUrl})
      : super(key: key);

  @override
  _HomeworkStudentAnswerShowState createState() =>
      _HomeworkStudentAnswerShowState();
}

class _HomeworkStudentAnswerShowState extends State<HomeworkStudentAnswerShow> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  TextEditingController note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar("اجابة طالب"),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: imageGrid(widget.contentUrl,
                        widget.data['homework_answers_imgs'])),
                Text(toDateAndTime(widget.data['created_at'], 12)),
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("الطالب: "),
                          Text(widget.data['homework_answers_student']
                                  ['account_name']
                              .toString()),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("الصف: "),
                          Text(widget.data['homework_answers_student']
                                      ['account_division_current']['class_name']
                                  .toString() +
                              " - " +
                              widget.data['homework_answers_student']
                                      ['account_division_current']['leader']
                                  .toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.data['homework_answers_text'] != null)
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(
                      widget.data['homework_answers_text'].toString(),
                      style:
                          const TextStyle(fontSize: 18, color: MyColor.purple),
                    ),
                  )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: MyColor.white0,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: const Offset(0, 0), // changes position of shadow
                ),
              ],
            ),
            //height: 40,
            width: Get.width,
            child: Center(
              child: MaterialButton(
                color: MyColor.purple,
                child: const Text(
                  "تصحيح الاجابة",
                  style: TextStyle(fontSize: 20, color: MyColor.yellow),
                ),
                textColor: MyColor.yellow,
                // colo
                // valueColor: MyColor.yellow,
                // successColor: MyColor.purple,
                // controller: _btnController,
                onPressed: _show,
              ),
            ),
          )
        ],
      ),
    );
  }

  _show() {
    Get.defaultDialog(
        title: "تصحيح اجابة طالب",
        content: GetBuilder<SelectSwitchProvider>(builder: (val) {
          return Column(
            children: [
              Row(
                children: [
                  Radio(
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => MyColor.purple),
                    focusColor: MaterialStateColor.resolveWith(
                        (states) => MyColor.purple),
                    value: 1,
                    groupValue: val.radioValue,
                    onChanged: val.change,
                  ),
                  const Text("صح"),
                ],
              ),
              Row(
                children: [
                  Radio(
                    fillColor: MaterialStateColor.resolveWith(
                        (states) => MyColor.purple),
                    focusColor: MaterialStateColor.resolveWith(
                        (states) => MyColor.purple),
                    value: 0,
                    groupValue: val.radioValue,
                    onChanged: val.change,
                  ),
                  const Text("خطأ"),
                ],
              ),
              const Text("ملاحظات حول الاجابة"),
              TextFormField(
                controller: note,
                maxLines: 3,
                minLines: 2,
                style: const TextStyle(
                  color: MyColor.black,
                ),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    hintText: "الملاحظات",
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
              ),
            ],
          );
        }),
        confirm: RoundedLoadingButton(
          color: MyColor.purple,
          child: const Text(
            "اضافة",
            style: TextStyle(fontSize: 20, color: MyColor.yellow),
          ),
          valueColor: MyColor.yellow,
          successColor: MyColor.purple,
          controller: _btnController,
          onPressed: _send,
          borderRadius: 10,
        ));
  }

  _send() {
    int? isCorrect = Get.put(SelectSwitchProvider()).radioValue;
    if (isCorrect == 0) {
    } else if (isCorrect == 1) {}
    Map _data = {
      "isCorrect": isCorrect == 0 ? false : true,
      "note": note.text,
      "homework_id": widget.data['_id']
    };
    NotificationsAPI().addCorrect(_data).then((res) {
      Get.back();
      if (!res['error']) {
        EasyLoading.showSuccess("تم تصحيح الاجابة");
      } else {
        EasyLoading.showError("يوجد خطأ ما");
      }
    });
  }
}
