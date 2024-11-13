import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../../api_connection/student/api_profile.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_random.dart';
import 'show/show_documents.dart';

class AttachDocuments extends StatefulWidget {
  const AttachDocuments({Key? key}) : super(key: key);

  @override
  _AttachDocumentsState createState() => _AttachDocumentsState();
}

class _AttachDocumentsState extends State<AttachDocuments> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  XFile? _pic1;
  XFile? _pic2;
  XFile? _pic3;
  XFile? _pic4;
  XFile? _pic5;

  pickImage1() async {
    EasyLoading.show(status: "loading".tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) => {
            setState(() {
              _pic1 = value;
            }),
            EasyLoading.dismiss(),
          });
    } else {
      EasyLoading.dismiss();
      // User canceled the picker
    }
  }

  pickImage2() async {
    EasyLoading.show(status: "loading".tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) => {
            setState(() {
              _pic2 = value;
            }),
            EasyLoading.dismiss(),
          });
    } else {
      EasyLoading.dismiss();
    }
  }

  pickImage3() async {
    EasyLoading.show(status: "loading".tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) => {
            setState(() {
              _pic3 = value;
            }),
            EasyLoading.dismiss(),
          });
    } else {
      EasyLoading.dismiss();
    }
  }

  pickImage4() async {
    EasyLoading.show(status: "loading".tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) => {
            setState(() {
              _pic4 = value;
            }),
            EasyLoading.dismiss(),
          });
    } else {
      EasyLoading.dismiss();
    }
  }

  pickImage5() async {
    EasyLoading.show(status: "loading".tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) => {
            setState(() {
              _pic5 = value;
            }),
            EasyLoading.dismiss(),
          });
    } else {
      EasyLoading.dismiss();
    }
  }

  bool activeNav = false;
  Map _documents = {};
  String _contentUrl = "";
  Future<XFile?> compressAndGetFile(XFile file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, "$targetPath/img_$getRand.jpg",
        quality: 20);
    return result;
  }

  _send() {
    dio.FormData data = dio.FormData.fromMap({
      "certificate_national_id_old_file": _documents['certificate_national_id'],
      "certificate_national_old_old_file":
          _documents['certificate_national_old'],
      "certificate_passport_old_file": _documents['certificate_passport'],
      "certificate_nationality_old_file": _documents['certificate_nationality'],
      "certificate_address_old_file": _documents['certificate_address'],
      "certificate_national_id": _pic1 == null
          ? null
          : dio.MultipartFile.fromFileSync(_pic1!.path,
              filename: 'pic.jpg', contentType: MediaType('image', 'jpg')),
      "certificate_national_old": _pic2 == null
          ? null
          : dio.MultipartFile.fromFileSync(_pic2!.path,
              filename: 'pic.jpg', contentType: MediaType('image', 'jpg')),
      "certificate_passport": _pic3 == null
          ? null
          : dio.MultipartFile.fromFileSync(_pic3!.path,
              filename: 'pic.jpg', contentType: MediaType('image', 'jpg')),
      "certificate_nationality": _pic4 == null
          ? null
          : dio.MultipartFile.fromFileSync(_pic4!.path,
              filename: 'pic.jpg', contentType: MediaType('image', 'jpg')),
      "certificate_address": _pic5 == null
          ? null
          : dio.MultipartFile.fromFileSync(_pic5!.path,
              filename: 'pic.jpg', contentType: MediaType('image', 'jpg')),
    });
    if (_pic1 == null &&
        _pic2 == null &&
        _pic3 == null &&
        _pic4 == null &&
        _pic5 == null) {
      _btnController.error();
      EasyLoading.showError("please choice all documents".tr);
      Timer(const Duration(seconds: 2), () {
        _btnController.reset();
      });
    } else {
      StudentProfileAPI().studentCertificateInsert(data).then((res) {
        if (res['error'] == false) {
          _showDocuments();
          _btnController.success();
          EasyLoading.showSuccess(res['message'].toString());
        } else {
          _btnController.error();
          EasyLoading.showError(res['message'].toString());
          Timer(const Duration(seconds: 2), () {
            _btnController.reset();
          });
        }
      });
    }
  }

  _showDocuments() {
    StudentProfileAPI().studentCertificateGet().then((res) {
      if (!res['error']) {
        if (res['results']['certificate_national_id'] == null &&
            res['results']['certificate_national_old'] == null &&
            res['results']['certificate_passport'] == null &&
            res['results']['certificate_nationality'] == null &&
            res['results']['certificate_address'] == null) {
        } else {
          setState(() {
            activeNav = true;
            _documents = res['results'];
            _contentUrl = res['content_url'];
          });
        }
      }
    });
  }

  @override
  void initState() {
    _showDocuments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.purple,
        title: Text(
          "Documents".tr,
          style: const TextStyle(color: MyColor.white0),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => activeNav
                ? Get.to(() => ShowDocument(
                      data: _documents,
                      url: _contentUrl,
                    ))
                : Get.snackbar("attention".tr, 'notUploadYet'.tr,
                    backgroundColor: Colors.orange, colorText: Colors.white),
            tooltip: 'viewDocument'.tr,
            icon: const Icon(LineIcons.fileInvoice),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _pic1 != null
                ? Container(
                    padding:
                        const EdgeInsets.only(right: 40, left: 40, top: 40),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_pic1!.path))),
                        Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _pic1 = null;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                              )),
                        ),
                      ],
                    ))
                : _buttons('Unified Card'.tr, pickImage1, LineIcons.plus, true),
            _pic2 != null
                ? Container(
                    padding:
                        const EdgeInsets.only(right: 40, left: 40, top: 40),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_pic2!.path))),
                        Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _pic2 = null;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                              )),
                        ),
                      ],
                    ))
                : _buttons('civilainCard'.tr, pickImage2, LineIcons.plus, true),
            _pic3 != null
                ? Container(
                    padding:
                        const EdgeInsets.only(right: 40, left: 40, top: 40),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_pic3!.path))),
                        Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _pic3 = null;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                              )),
                        ),
                      ],
                    ))
                : _buttons('passpord'.tr, pickImage3, LineIcons.plus, true),
            _pic4 != null
                ? Container(
                    padding:
                        const EdgeInsets.only(right: 40, left: 40, top: 40),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_pic4!.path))),
                        Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _pic4 = null;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                              )),
                        ),
                      ],
                    ))
                : _buttons("Certificate of Nationality".tr, pickImage4,
                    LineIcons.plus, true),
            _pic5 != null
                ? Container(
                    padding:
                        const EdgeInsets.only(right: 40, left: 40, top: 40),
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_pic5!.path))),
                        Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _pic5 = null;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                              )),
                        ),
                      ],
                    ))
                : _buttons(
                    'residence card'.tr, pickImage5, LineIcons.plus, true),
            const SizedBox(
              height: 20,
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
