import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../../../api_connection/teacher/api_notification.dart';
import '../../../../api_connection/teacher/api_other.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_random.dart';

class NotificationAdd extends StatefulWidget {
  const NotificationAdd({super.key});

  @override
  _NotificationAddState createState() => _NotificationAddState();
}

class _NotificationAddState extends State<NotificationAdd> {
  final _formValidate = GlobalKey<FormState>();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _link = TextEditingController();

  final MainDataGetProvider _mainDataProvider = Get.put(MainDataGetProvider());
  final List notificationSubjectType = ['واجب بيتي', 'ملخص', 'امتحان يومي'];

  ///-------------------------
  String? _notificationType = '';
  List<S2Choice<String>> notificationType = [
    //S2Choice<String>(value: "رسالة", title: "رسالة"),
  ];
  String? _notificationSubject = '';
  List<S2Choice<String>> notificationSubject = [];

  ///-------------------------
  String _receiver = '';
  List<S2Choice<String>> receiver = [
    S2Choice<String>(value: "الطلاب", title: "Students"),
    S2Choice<String>(value: "الصفوف والشعب", title: "Classes and Sections"),
  ];

  ///-------------------------
  List<String> _classes = [];
  List<S2Choice<String>> classes = [];
  List<String> _student = [];
  List<S2Choice<String>> student = [];

  bool _isLoadingStudents = false;
  bool _isLoadingNotifications = false;
  bool _isLoadingSubjects = false;

  ///-------------------------

  final List<File> _pic = [];
  Future<XFile?> compressAndGetFile(File file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, "$targetPath/img_$getRand.jpg",
        quality: 40);
    return result;
  }

  File? _pdf;
  pickPdf() async {
    EasyLoading.show(status: "Loading ....");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ["pdf"]);
    //application/pdf
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _pdf = file;
      });
      // List<File> files = result.paths.map((path) => File(path)).toList();
      // _pic.clear();
      // for (var file in files) {
      //   await compressAndGetFile(file, p.dirname(file.path)).then((value) => {
      //     _pic.add(value),
      //   });
      // }
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
    }
  }

  pickImage1() async {
    EasyLoading.show(status: "Loading ...");
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    //70568
    if (result != null) {
      if (result.files.length > 11) {
        EasyLoading.dismiss();
        EasyLoading.showError("Can not upload more than 10 images");
      } else {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        _pic.clear();
        for (var file in files) {
          await compressAndGetFile(file, p.dirname(file.path)).then((value) => {
                _pic.add(File(value!.path)),
              });
        }
        setState(() {});
        EasyLoading.dismiss();
      }
    } else {
      EasyLoading.dismiss();
    }
  }

  _showStudent() async {
    setState(() => _isLoadingStudents = true);

    List accountDivision = [];
    for (Map division in _mainDataProvider.mainData['account']
        ['account_division']) {
      accountDivision.add(division['_id']);
    }
    Map data = {
      "study_year": _mainDataProvider.mainData['setting'][0]['setting_year'],
      "class_school": accountDivision
    };
    await Future.delayed(const Duration(minutes: 1));
    OtherApi().getStudent(data, true).then((res) {
      for (Map _data in res) {
        student.add(S2Choice<String>(
            value: _data['_id'],
            title: _data['account_name'],
            group:
                "${_data['account_division_current']['class_name']} - ${_data['account_division_current']['leader']}"));
      }
      if (mounted) setState(() => _isLoadingStudents = false);
    });
  }

  _showNotification() async {
    setState(() => _isLoadingNotifications = true);

    OtherApi().getNotificationList().then((res) {
      for (int i = 0; i < res.length; i++) {
        notificationType.add(S2Choice<String>(value: res[i], title: res[i]));
      }
      setState(() => _isLoadingNotifications = false);
    });
  }

  _showNotificationSubject() async {
    setState(() => _isLoadingSubjects = true);

    List accountDivision = [];
    if (_mainDataProvider.mainData['account']['account_subject'] != null) {
      for (Map subject in _mainDataProvider.mainData['account']
          ['account_subject']) {
        accountDivision.add(subject['_id']);
        notificationSubject.add(S2Choice<String>(
          value: subject['subject_name'],
          title: subject['subject_name'],
        ));
      }
    }
    setState(() => _isLoadingSubjects = false);
  }

  _send() {
    if (_receiver == '' || (_classes.isEmpty && _student.isEmpty)) {
      _btnController.error();
      Timer(const Duration(seconds: 2), () {
        _btnController.reset();
      });
      EasyLoading.showError("Must select recivies");
    } else {
      if (_notificationType == '') {
        _btnController.error();
        Timer(const Duration(seconds: 2), () {
          _btnController.reset();
        });
        EasyLoading.showError("Must choose Notification type");
      } else {
        if (_formValidate.currentState!.validate()) {
          List<dio.MultipartFile> localPic = [];
          for (int i = 0; i < _pic.length; i++) {
            localPic.add(dio.MultipartFile.fromFileSync(_pic[i].path,
                filename: 'pic$i.jpg', contentType: MediaType('image', 'jpg')));
          }
          dio.FormData data = dio.FormData.fromMap({
            "notifications_student_id": _receiver == "الطلاب" ? _student : null,
            "notifications_class_school_id":
                _receiver == "الصفوف والشعب" ? _classes : null,
            "notifications_type": _notificationType,
            "notifications_title": _title.text,
            "notifications_description":
                _description.text.isEmpty ? null : _description.text,
            "notifications_link": _link.text.isEmpty ? null : _link.text,
            "notifications_subject":
                _notificationSubject != "" ? _notificationSubject : null,
            "photos": localPic.isEmpty ? null : localPic,
            "pdf": _pdf == null
                ? null
                : dio.MultipartFile.fromFileSync(_pdf!.path,
                    filename: 'file.pdf',
                    contentType: MediaType('application', 'pdf')),
            "notifications_study_year": _mainDataProvider.mainData['setting'][0]
                ['setting_year'],
          });
          NotificationsAPI().addNotification(data).then((res) {
            if (res['error'] == false) {
              _btnController.success();
              Timer(const Duration(seconds: 2), () {
                Get.back();
              });
            } else {
              _btnController.error();
              Timer(const Duration(seconds: 2), () {
                _btnController.reset();
              });
            }
          });
        } else {
          _btnController.error();
          Timer(const Duration(seconds: 2), () {
            _btnController.reset();
          });
        }
      }
    }
  }

  @override
  void initState() {
    _showStudent();
    _showNotification();
    _showNotificationSubject();
    for (var _data in _mainDataProvider.mainData['account']
        ['account_division']) {
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
      appBar: myAppBar("Add Notification"),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(right: 15, left: 15),
                          child: const Text(
                            "Select Recivies",
                            style: TextStyle(fontSize: 17),
                          )),
                      Center(
                        child: Container(
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
                            title: "",
                            placeholder: 'Choose',
                            selectedValue: _receiver,
                            choiceItems: receiver,
                            onChange: (selected) =>
                                setState(() => _receiver = selected.value),
                          ),
                        ),
                      ),
                      if (_receiver == "الطلاب")
                        _isLoadingStudents
                            ? const _LoadingText("Loading students data…")
                            : Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, bottom: 10, right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: MyColor.purple,
                                    ),
                                    color: MyColor.white1,
                                  ),
                                  child: SmartSelect<String>.multiple(
                                    title: "Students",
                                    placeholder: 'choose',
                                    selectedValue: _student,
                                    choiceGrouped: true,
                                    onChange: (selected) {
                                      setState(() => _student = selected.value);
                                      //_showData(selected.value);
                                    },
                                    groupHeaderStyle: const S2GroupHeaderStyle(
                                        backgroundColor: MyColor.white4),
                                    choiceItems: student,
                                    modalFilter: true,
                                    modalFilterAuto: true,
                                  ),
                                ),
                              ),
                      if (_receiver == "الصفوف والشعب")
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
                            child: SmartSelect<String>.multiple(
                              title: "Classes and Sections",
                              placeholder: 'Choose',
                              selectedValue: _classes,
                              choiceGrouped: true,
                              onChange: (selected) {
                                setState(() => _classes = selected.value);
                                //_showData(selected.value);
                              },
                              groupHeaderStyle: const S2GroupHeaderStyle(
                                  backgroundColor: MyColor.white4),
                              choiceItems: classes,
                              modalFilter: true,
                              modalFilterAuto: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(right: 15, left: 15),
                          child: const Text(
                            "Notification Type",
                            style: TextStyle(fontSize: 17),
                          )),
                      _isLoadingNotifications
                          ? const _LoadingText("Loading notification types...")
                          : Center(
                              child: Container(
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
                                  title: "Notification",
                                  placeholder: 'choose',
                                  selectedValue: _notificationType!,
                                  choiceItems: notificationType,
                                  onChange: (selected) => setState(() {
                                    _notificationType = selected.value;
                                  }),
                                ),
                              ),
                            ),
                      if (notificationSubjectType.contains(_notificationType))
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 10, bottom: 10, right: 10, left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: MyColor.purple,
                              ),
                              color: MyColor.white1,
                            ),
                            child: _isLoadingSubjects
                                ? const _LoadingText("Loading Subject...")
                                : SmartSelect<String>.single(
                                    title: "Subject",
                                    placeholder: 'choose',
                                    selectedValue: _notificationSubject!,
                                    choiceItems: notificationSubject,
                                    onChange: (selected) => setState(() {
                                      _notificationSubject = selected.value;
                                    }),
                                  ),
                          ),
                        ),
                      //notificationSubjectType
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  child: Form(
                    key: _formValidate,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(right: 15, left: 15),
                            child: const Text(
                              "Detailes",
                              style: TextStyle(fontSize: 17),
                            )),
                        _formText(_title, "Address"),
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 200, maxWidth: 350),
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: TextFormField(
                              controller: _description,
                              style: const TextStyle(
                                color: MyColor.red,
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: 3,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                  //contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                                  contentPadding: const EdgeInsets.all(12.0),
                                  hintText: "Detailes",
                                  isDense: true,
                                  errorStyle:
                                      const TextStyle(color: MyColor.red),
                                  fillColor: MyColor.white1,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.white1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.white1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.white1,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.white1,
                                    ),
                                  ),
                                  filled: true
                                  //fillColor: Colors.green
                                  ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 200, maxWidth: 350),
                            padding: const EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: TextFormField(
                              controller: _link,
                              style: const TextStyle(
                                color: MyColor.grayDark,
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                  //contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                                  contentPadding: const EdgeInsets.all(12.0),
                                  hintText: "Add Link",
                                  isDense: true,
                                  errorStyle:
                                      const TextStyle(color: MyColor.red),
                                  fillColor: MyColor.white1,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.white1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.white1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.white1,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    borderSide: const BorderSide(
                                      color: MyColor.red,
                                    ),
                                  ),
                                  filled: true
                                  //fillColor: Colors.green
                                  ),
                            ),
                          ),
                        ),
                        _pdf != null
                            ? Center(
                                child: MaterialButton(
                                  color: MyColor.purple,
                                  textColor: MyColor.white0,
                                  child: const Text("Cancel pdf"),
                                  onPressed: () {
                                    setState(() {
                                      _pdf = null;
                                    });
                                  },
                                ),
                              )
                            : _buttons(
                                "Add Files", pickPdf, LineIcons.pdfFile, true),
                        _pic.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, top: 40),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            for (var img in _pic)
                                              _imageListView(img),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _pic.clear();
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                          )),
                                    ),
                                  ],
                                ))
                            : _buttons("Add Images", pickImage1,
                                LineIcons.image, true),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
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
              child: RoundedLoadingButton(
                color: MyColor.purple,
                valueColor: MyColor.yellow,
                successColor: MyColor.purple,
                controller: _btnController,
                onPressed: _send,
                borderRadius: 10,
                child: const Text(
                  "Send",
                  style: TextStyle(
                      fontSize: 20, color: MyColor.yellow, letterSpacing: 2),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _formText(control, hintText) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        child: TextFormField(
          controller: control,
          style: const TextStyle(
            color: MyColor.grayDark,
          ),
          keyboardType: TextInputType.text,
          maxLines: null,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
              //contentPadding: EdgeInsets.symmetric(vertical: 12.0),
              contentPadding: const EdgeInsets.all(12.0),
              hintText: hintText,
              isDense: true,
              errorStyle: const TextStyle(color: MyColor.red),
              fillColor: MyColor.white1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: MyColor.white1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                  color: MyColor.white1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: MyColor.white1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(
                  color: MyColor.red,
                ),
              ),
              filled: true
              //fillColor: Colors.green
              ),
          // validator: (value) {
          //   var result = value.length < 3 ? tr("fillText") : null;
          //   return result;
          // },
        ),
      ),
    );
  }

  _imageListView(img) {
    return Container(
      height: 150,
      width: Get.width / 4,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: MyColor.white3),
        borderRadius: const BorderRadius.all(
            Radius.circular(11) //                 <--- border radius here
            ),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(img, fit: BoxFit.cover)),
    );
  }

  _buttons(t, nav, icon, enable) {
    return Container(
      decoration: BoxDecoration(
        color: MyColor.purple,
        borderRadius: BorderRadius.circular(5.0),
      ),
      margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
      child: ListTile(
        onTap: nav,
        enabled: enable,
        title: Text(
          t,
          maxLines: 1,
          style: const TextStyle(color: MyColor.yellow, fontSize: 15),
        ),
        trailing: Icon(
          icon,
          color: MyColor.yellow,
        ),
      ),
    );
  }
}

class _LoadingText extends StatelessWidget {
  final String text;
  const _LoadingText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: MyColor.yellow,
              ),
              const SizedBox(height: 10),
              Text(text),
            ],
          ),
        ),
      );
}
