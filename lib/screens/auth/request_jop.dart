import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../api_connection/student/api_general_data.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_random.dart';

class RequestJop extends StatefulWidget {
  const RequestJop({Key? key}) : super(key: key);
  @override
  _RequestJopState createState() => _RequestJopState();
}

class _RequestJopState extends State<RequestJop> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone1 = TextEditingController();
  final TextEditingController _phone2 = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _degree = TextEditingController();
  final TextEditingController _college = TextEditingController();
  final TextEditingController _yearGraduate = TextEditingController();
  final TextEditingController _lastWork = TextEditingController();
  final TextEditingController _nearestLandmark = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _addressM = TextEditingController();
  final TextEditingController _addressD = TextEditingController();
  final TextEditingController _addressZ = TextEditingController();

  final _formValidate = GlobalKey<FormState>();
  XFile? _pic;
  DateTime _date = DateTime.now();
  String _socialStatus = '';
  List<S2Choice<String>> socialStatus = [
    S2Choice<String>(value: "اعزب", title: 'single'.tr),
    S2Choice<String>(value: "متزوج", title: "married".tr),
    S2Choice<String>(value: "مطلق", title: "dev".tr),
    S2Choice<String>(value: "ارمل", title: "widow".tr),
  ];
  final _focusNode = FocusNode();
  pickImage() async {
    EasyLoading.show(status: 'loading'.tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((XFile? value) => {
            setState(() {
              _pic = value;
            }),
            EasyLoading.dismiss(),
          });
    } else {
      EasyLoading.dismiss();
      // User canceled the picker
    }
  }

  Future<XFile?> compressAndGetFile(File file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, "$targetPath/img_$getRand.jpg",
        quality: 20);
    return result;
  }

  _send() async {
    if (_formValidate.currentState!.validate()) {
      if (_pic != null) {
        //todo change school id
        var data = {
          "name": _name.text,
          "image":
              "data:image/jpeg;base64,${base64Encode(await _pic!.readAsBytes())}",
          "birthday": _birthday.text,
          "degree": _degree.text,
          "college": _college.text,
          "year_graduate": _yearGraduate.text,
          "phone1": _phone1.text,
          "phone2": _phone2.text,
          "social_status": _socialStatus,
          "last_work": _lastWork.text,
          "nearest_landmark": _nearestLandmark.text,
          "address": _address.text,
          "address_m": _addressM.text,
          "address_d": _addressD.text,
          "address_z": _addressZ.text,
        };

        GeneralData().hireRequest(data).then((res) {
          _btnController.reset();
          if (res['error'] == false) {
            _btnController.success();
          } else {
            _btnController.error();
          }
        });
      } else {
        EasyLoading.show(status: 'plsImg'.tr, dismissOnTap: true);
        Timer(const Duration(seconds: 2), () {
          EasyLoading.dismiss();
        });
        _btnController.reset();
      }
    } else {
      _btnController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        title: Text(
          'appointment'.tr,
          style: const TextStyle(color: MyColor.purple),
        ),
        iconTheme: const IconThemeData(
          color: MyColor.purple,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: MyColor.white0,
        child: Form(
          key: _formValidate,
          child: Container(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _formText(_name, 'fName'.tr),
                  if (_pic != null)
                    Container(
                        padding:
                            const EdgeInsets.only(right: 40, left: 40, top: 40),
                        child: Stack(
                          children: [
                            Image.file(File(_pic!.path)),
                            Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _pic = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  )),
                            ),
                          ],
                        )),
                  Container(
                    constraints:
                        const BoxConstraints(minWidth: 200, maxWidth: 350),
                    padding:
                        const EdgeInsets.only(top: 10, right: 20, left: 20),
                    child: MaterialButton(
                        height: 45,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        color: MyColor.purple,
                        onPressed: pickImage,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'uImg'.tr,
                              style: const TextStyle(
                                  color: MyColor.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        )),
                  ),
                  _formTextBirthday(_birthday, 'birthDate'.tr),
                  _formText(_degree, 'deg'.tr),
                  _formText(_college, 'university'.tr),
                  _formText(_yearGraduate, 'collegeG'.tr),
                  _formText(_phone1, 'phone1'.tr),
                  _formText(_phone2, 'phone2'.tr),
                  _formText(_address, 'Address'.tr),
                  _formText(_addressM, "street".tr),
                  _formText(_addressD, "home".tr),
                  _formText(_addressZ, 'district'.tr),
                  _formText(_nearestLandmark, 'nearestPoint'.tr),
                  _formText(_lastWork, 'prevJob'.tr),
                  Container(
                    constraints: const BoxConstraints(
                        minWidth: 200, maxWidth: 350, maxHeight: 73),
                    margin: const EdgeInsets.only(
                        top: 0, bottom: 0, right: 0, left: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: MyColor.purple,
                      ),
                      color: MyColor.white1,
                    ),
                    child: SmartSelect<String>.single(
                      title: 'socHala'.tr,
                      selectedValue: _socialStatus,
                      choiceItems: socialStatus,
                      placeholder: 'pickSoHala'.tr,
                      onChange: (selected) {
                        setState(() => _socialStatus = selected.value);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: RoundedLoadingButton(
                      color: MyColor.purple,
                      valueColor: MyColor.yellow,
                      successColor: MyColor.purple,
                      controller: _btnController,
                      onPressed: _send,
                      borderRadius: 10,
                      child: Text("send".tr,
                          style: const TextStyle(
                              color: MyColor.white0,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  )
                ],
              ),
            ),
          ),
        ),
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
            color: MyColor.black,
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
          validator: (value) {
            var result = value!.length < 3 ? "please fill all field".tr : null;
            return result;
          },
        ),
      ),
    );
  }

  //birthday  form Text
  _formTextBirthday(control, hintText) {
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
            color: MyColor.black,
          ),
          keyboardType: TextInputType.text,
          // readOnly: true,
          onTap: () {
            _focusNode.unfocus();
            _selectDate(context);
          },
          focusNode: _focusNode,
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
          validator: (value) {
            //validate date format yyyy-MM-dd
            if (value!.isEmpty) {
              return "please fill all field".tr;
            } else if (!RegExp(r"^\d{4}-\d{2}-\d{2}$").hasMatch(value)) {
              return 'errDate'.tr;
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }

  //date picker
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (picked != null && picked != _date) {
      _date = picked;
      _birthday.text = DateFormat('yyyy-MM-dd').format(_date);
    }
  }
}
