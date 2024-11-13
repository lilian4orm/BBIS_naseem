import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_awesome_select/flutter_awesome_select.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../api_connection/student/api_general_data.dart';
import '../../../static_files/my_color.dart';
import 'join_us_page.dart';

class JoinSchool extends StatefulWidget {
  const JoinSchool({Key? key}) : super(key: key);

  @override
  State<JoinSchool> createState() => _JoinSchoolState();
}

class _JoinSchoolState extends State<JoinSchool> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController name = TextEditingController();
  final TextEditingController birthDay = TextEditingController();
  final TextEditingController brotherNumbers = TextEditingController();

  ///التحصيل الدراسي للاب
  final TextEditingController fathersStudy = TextEditingController();
  final TextEditingController fathersJob = TextEditingController();

  ///التحصيل الدراسي للام
  final TextEditingController mothersStudy = TextEditingController();
  final TextEditingController mothersJob = TextEditingController();
  final TextEditingController previouslyKindergartenName =
      TextEditingController();
  final TextEditingController currentSchoolName = TextEditingController();
  final TextEditingController reasonSchoolName = TextEditingController();
  final TextEditingController reason = TextEditingController();
  final TextEditingController locality = TextEditingController();
  final TextEditingController alley = TextEditingController();
  final TextEditingController house = TextEditingController();
  final TextEditingController nearestPoint = TextEditingController();
  final TextEditingController fatherPhone = TextEditingController();
  final TextEditingController motherPhone = TextEditingController();
  final TextEditingController address = TextEditingController();
  bool liveWithParents = true;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeN = FocusNode();
  final _formValidate = GlobalKey<FormState>();
  String sequence = '';
  List<S2Choice<String>> sequenceList = [
    S2Choice<String>(value: "الوحيد", title: 'alone'.tr),
    S2Choice<String>(value: "الاول", title: "first".tr),
    S2Choice<String>(value: "الوسط", title: "mid".tr),
    S2Choice<String>(value: "الاخير", title: "last".tr),
  ];
  String currentStage = '';
  List<S2Choice<String>> currentStageList = [
    S2Choice<String>(value: "الاول الابتدائي", title: '1stclass'.tr),
    S2Choice<String>(value: "الثاني الابتدائي", title: '2ndclass'.tr),
    S2Choice<String>(value: "الثالث الابتدائي", title: '3rdclass'.tr),
    S2Choice<String>(value: "الرابع الابتدائي", title: '4thclass'.tr),
    S2Choice<String>(value: "الخامس الابتدائي", title: '5thclass'.tr),
    S2Choice<String>(value: "السادس الابتدائي", title: '6thclass'.tr),
  ];
  String? image;

  _send() {
    if (_formValidate.currentState!.validate()) {
      if (sequence == "") {
        _btnController.error();
        EasyLoading.showInfo('pickChildTas'.tr);
        _btnController.reset();
        return;
      }
      Map data = {
        "student_name": name.text,
        "student_birthday": birthDay.text,
        "student_class": currentStage,
        "student_brother_number": brotherNumbers.text,
        "mother_degree": mothersStudy.text,
        "father_degree": fathersStudy.text,
        "father_jop": fathersJob.text,
        "mother_jop": mothersJob.text,
        "past_kindergarten": previouslyKindergartenName.text,
        "school_name": currentSchoolName.text,
        "past_school_reason": reasonSchoolName.text,
        "student_stying_with": reason.text,
        "address_m": locality.text,
        "address_z": alley.text,
        "address_d": house.text,
        "nearest_landmark": nearestPoint.text,
        "father_phone": fatherPhone.text,
        "mother_phone": motherPhone.text,
        "is_staying_with_his_fathers": liveWithParents,
        "student_brother_rank": sequence,
        "student_image": image,
        "address": address.text,
      };
      GeneralData().joinUsSchool(data).then((res) {
        if (res['error'] == false) {
          _btnController.success();
        } else {
          _btnController.error();
        }
      });
    } else {
      _btnController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formValidate,
      child: Container(
        padding: const EdgeInsets.only(right: 20, left: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: MyColor.grayDark,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        pickImageSingleGallery().then((String value) {
                          setState(() {
                            image = value;
                          });
                        });
                      },
                      child: image != null
                          ? CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(
                                base64Decode(image!.split(',')[1]),
                              ),
                            )
                          : const Icon(
                              Icons.add_a_photo,
                              color: MyColor.grayDark,
                              size: 50,
                            ),
                    ),
                  ),
                ],
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: name,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('fNaSt'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 5) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: birthDay,
                  focusNode: _focusNode,
                  onTap: () {
                    _focusNode.unfocus();
                    selectDate(context);
                  },
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('stBirth'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 5) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                    minWidth: 200, maxWidth: 350, maxHeight: 73),
                margin: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 0, left: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: MyColor.purple,
                  ),
                  color: MyColor.white1,
                ),
                //_schoolType
                child: SmartSelect<String>.single(
                  title: 'curS'.tr,
                  selectedValue: currentStage,
                  placeholder: "pick".tr,
                  choiceItems: currentStageList,
                  onChange: (selected) => setState(() {
                    currentStage = selected.value;
                  }),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: brotherNumbers,
                  focusNode: _focusNodeN,
                  onTap: () {
                    _focusNodeN.unfocus();
                    showPicker();
                  },
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.phone,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('broCo'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.isEmpty) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                    minWidth: 200, maxWidth: 350, maxHeight: 73),
                margin: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 0, left: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: MyColor.purple,
                  ),
                  color: MyColor.white1,
                ),
                //_schoolType
                child: SmartSelect<String>.single(
                  title: 'stSeq'.tr,
                  selectedValue: sequence,
                  placeholder: "pick".tr,
                  choiceItems: sequenceList,
                  onChange: (selected) => setState(() {
                    sequence = selected.value;
                  }),
                ),
              ),
              Container(
                constraints: const BoxConstraints(
                    minWidth: 200, maxWidth: 350, maxHeight: 73),
                margin: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 0, left: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: MyColor.purple,
                  ),
                  color: MyColor.white1,
                ),
                //_schoolType
                child: CheckboxListTile(
                    title: Text('stWithParent'.tr),
                    value: liveWithParents,
                    activeColor: MyColor.green,
                    onChanged: (value) {
                      setState(() {
                        liveWithParents = value!;
                      });
                    }),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: reason,
                  enabled: !liveWithParents,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 2,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('livMen'.tr),
                  // validator: (value) {
                  //   assert(value != null);
                  //   if (value!.length < 5) {
                  //     return "الرجاء ملئ البيانات";
                  //   }
                  //   return null;
                  // },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: fathersStudy,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('fathd'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 3) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: fathersJob,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('fatJ'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 3) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: mothersStudy,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('mamd'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 3) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: mothersJob,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('mamj'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 3) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: previouslyKindergartenName,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('lastSchool'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 3) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: currentSchoolName,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('cSchool'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 3) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: reasonSchoolName,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: inputDecoration('trRea'.tr),
                  validator: (value) {
                    assert(value != null);
                    if (value!.length < 3) {
                      return "please fill all field".tr;
                    }
                    return null;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: MyColor.white1.withOpacity(.3),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Text('dieRe'.tr,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: MyColor.black),
                    textAlign: TextAlign.justify),
              ),
              const Divider(),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: MyColor.purple.withOpacity(.5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Address".tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 200, maxWidth: 350),
                      padding: const EdgeInsets.all(5),
                      child: TextFormField(
                        controller: address,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          color: MyColor.grayDark,
                        ),
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: inputDecoration("region".tr),
                        validator: (value) {
                          assert(value != null);
                          if (value!.length < 3) {
                            return "please fill all field".tr;
                          }
                          return null;
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: TextFormField(
                              controller: locality,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                color: MyColor.grayDark,
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: inputDecoration("city".tr),
                              validator: (value) {
                                assert(value != null);
                                if (value!.isEmpty) {
                                  return "please fill all field".tr;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: TextFormField(
                              controller: alley,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                color: MyColor.grayDark,
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: inputDecoration("alley".tr),
                              validator: (value) {
                                assert(value != null);
                                if (value!.isEmpty) {
                                  return "please fill all field".tr;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: TextFormField(
                              controller: house,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                color: MyColor.grayDark,
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: inputDecoration("home".tr),
                              validator: (value) {
                                assert(value != null);
                                if (value!.isEmpty) {
                                  return "please fill all field".tr;
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 200, maxWidth: 350),
                      padding: const EdgeInsets.all(5),
                      child: TextFormField(
                        controller: nearestPoint,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(
                          color: MyColor.grayDark,
                        ),
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: inputDecoration("theNearestPoint".tr),
                        validator: (value) {
                          assert(value != null);
                          if (value!.length < 3) {
                            return "please fill all field".tr;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: fatherPhone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.phone,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                      //contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      contentPadding: const EdgeInsets.all(12.0),
                      hintText: 'fatPhone'.tr,
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
                    assert(value != null);
                    RegExp regExp = RegExp(
                      r"^0{1}7{1}[8,9,6,7,5,4]{1}[\d]{8}",
                      caseSensitive: false,
                      multiLine: false,
                    );
                    RegExp regExpFirstNumber = RegExp(
                      r"0{1}7{1}",
                      caseSensitive: false,
                      multiLine: false,
                    );
                    RegExp regExpThirdNumber = RegExp(
                      r"0{1}7{1}[7,6,5,8,9]{1}",
                      caseSensitive: false,
                      multiLine: false,
                    );
                    if (regExpFirstNumber.hasMatch(value!)) {
                      if (regExpThirdNumber.hasMatch(value)) {
                        if (value.length == 11) {
                          if (regExp.hasMatch(value)) {
                            return null;
                          } else {
                            return 'ph1chk'.tr;
                          }
                        } else {
                          return 'pho11chk'.tr;
                        }
                      } else {
                        return 'phoCorst'.tr;
                      }
                    } else {
                      return 'phoSt'.tr;
                    }
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: motherPhone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.phone,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                      //contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      contentPadding: const EdgeInsets.all(12.0),
                      hintText: "momPhone".tr,
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
                    assert(value != null);
                    RegExp regExp = RegExp(
                      r"^0{1}7{1}[8,9,6,7,5,4]{1}[\d]{8}",
                      caseSensitive: false,
                      multiLine: false,
                    );
                    RegExp regExpFirstNumber = RegExp(
                      r"0{1}7{1}",
                      caseSensitive: false,
                      multiLine: false,
                    );
                    RegExp regExpThirdNumber = RegExp(
                      r"0{1}7{1}[7,6,5,8,9]{1}",
                      caseSensitive: false,
                      multiLine: false,
                    );
                    if (regExpFirstNumber.hasMatch(value!)) {
                      if (regExpThirdNumber.hasMatch(value)) {
                        if (value.length == 11) {
                          if (regExp.hasMatch(value)) {
                            return null;
                          } else {
                            return 'ph1chk'.tr;
                          }
                        } else {
                          return 'pho11chk'.tr;
                        }
                      } else {
                        return 'phoCorst'.tr;
                      }
                    } else {
                      return 'phoSt'.tr;
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: RoundedLoadingButton(
                  color: MyColor.yellow,
                  valueColor: MyColor.yellow,
                  successColor: MyColor.purple,
                  controller: _btnController,
                  onPressed: _send,
                  resetAfterDuration: true,
                  resetDuration: const Duration(seconds: 10),
                  borderRadius: 10,
                  child: Text("send".tr,
                      style: const TextStyle(
                          color: MyColor.black,
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
    );
  }

  int _selectedValue = 0;
  void selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 1460)),
      firstDate: DateTime.now().subtract(const Duration(days: 5475)),
      lastDate: DateTime.now().subtract(const Duration(days: 1460)),
    );
    if (picked != null) {
      String year = picked.year.toString();
      String month = picked.month.toString();
      String day = picked.day.toString();
      String date = "$year-$month-$day";
      birthDay.text = date;
    }
  }

  void showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 200.0,
            child: Column(
              children: [
                const SizedBox(height: 20.0),
                const Text('عدد الاخوة'),
                const SizedBox(height: 20.0),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: _selectedValue),
                    itemExtent: 40.0,
                    backgroundColor: Colors.white,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _selectedValue = index;
                      });
                    },
                    children: List<Widget>.generate(11, (int index) {
                      return Center(
                        child: Text('$index'),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    brotherNumbers.text = _selectedValue.toString();
                    Get.back();
                  },
                  child: const Text('Select'),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          );
        }).then((value) {
      if (value != null) {
        setState(() {
          // _selectedValue = value;
        });
      }
    });
  }
}

InputDecoration inputDecoration(String hintText) {
  return InputDecoration(
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
      );
}
