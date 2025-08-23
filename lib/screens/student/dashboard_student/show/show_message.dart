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
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../api_connection/student/api_notification.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_image_grid.dart';
import '../../../../static_files/my_pdf_viewr.dart';
import '../../../../static_files/my_random.dart';
import '../../../../static_files/my_times.dart';

class ShowMessage extends StatefulWidget {
  final Map data;
  final String contentUrl;
  final String notificationsType;
  final VoidCallback? onUpdate;

  const ShowMessage(
      {super.key,
      required this.data,
      required this.contentUrl,
      required this.notificationsType,
      this.onUpdate});

  @override
  _ShowMessageState createState() => _ShowMessageState();
}

class _ShowMessageState extends State<ShowMessage> {
  //["رسالة","تبليغ","واجب بيتي","ملخص","تقرير"]
  void _launchURL(url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';

  @override
  void initState() {
    if (!widget.data['isRead']) {
      widget.onUpdate?.call();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(widget.data['notifications_title'].toString()),
      body: ListView(
        children: [
          if (widget.data['notifications_description'] != null)
            Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                widget.data['notifications_description'].toString(),
                style: const TextStyle(fontSize: 18, color: MyColor.purple),
              ),
            ),

          // if (widget.notificationsType == "واجب بيتي")
          //   Padding(
          //     padding: const EdgeInsets.only(right: 20, left: 20),
          //     child: MaterialButton(
          //       onPressed: () => showMaterialModalBottomSheet(
          //         context: context,
          //         expand: true,
          //         builder: (context) => AddAnswer(data: widget.data),
          //       ),
          //       child: const Text(
          //         "اضافة اجابة",
          //         style: TextStyle(color: MyColor.purple),
          //       ),
          //       color: MyColor.yellow,
          //     ),
          //   ),
          if (widget.data['notifications_link'] != "" &&
              widget.data['notifications_link'] != null)
            InkWell(
              onTap: () => _launchURL(widget.data['notifications_link']),
              child: Container(
                margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: MyColor.purple.withOpacity(.17),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    widget.data['notifications_link'].toString(),
                    style: const TextStyle(fontSize: 18, color: MyColor.purple),
                  ),
                ),
              ),
            ),
          if (widget.data['notifications_pdf'] != "" &&
              widget.data['notifications_pdf'] != null)
            InkWell(
              onTap: () => Get.to(() => PdfViewer(
                  url: widget.contentUrl + widget.data['notifications_pdf'])),
              child: Container(
                margin: const EdgeInsets.only(right: 20, left: 20, top: 10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: MyColor.yellow.withOpacity(.9),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'pdfShow'.tr,
                    style: const TextStyle(fontSize: 18, color: MyColor.purple),
                  ),
                ),
              ),
            ),

          widget.data['notifications_imgs'] == null
              ? Container(height: 10)
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: imageGrid(
                      widget.contentUrl, widget.data['notifications_imgs'])),
          if (widget.data['notifications_sender'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${'sender'.tr} : "),
                  Text(widget.data['notifications_sender']['account_name']
                      .toString()),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(toDateAndTime(widget.data['created_at'], 12)),
          ),
          const SizedBox(
            height: 32,
          )
        ],
      ),
    );
  }
}

class AddAnswer extends StatefulWidget {
  final Map data;

  const AddAnswer({super.key, required this.data});

  @override
  _AddAnswerState createState() => _AddAnswerState();
}

class _AddAnswerState extends State<AddAnswer> {
  final TextEditingController _answerText = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final List<XFile> _pic = [];

  Future<XFile?> compressAndGetFile(XFile file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, "$targetPath/img_$getRand.jpg",
        quality: 40);
    return result;
  }

  pickImage1() async {
    EasyLoading.show(status: 'loading'.tr);
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    //70568
    if (result != null) {
      if (result.files.length > 10) {
        EasyLoading.dismiss();
        EasyLoading.showError('max!0img'.tr);
      } else {
        List<XFile> files = result.paths.map((path) => XFile(path!)).toList();
        _pic.clear();
        for (var file in files) {
          await compressAndGetFile(file, p.dirname(file.path)).then((value) => {
                _pic.add(value!),
              });
        }
        setState(() {});
        EasyLoading.dismiss();
      }
    } else {
      EasyLoading.dismiss();
    }
  }

  _send() {
    if (_pic.isNotEmpty || _answerText.text.isNotEmpty) {
      List<dio.MultipartFile> localPic = [];
      for (int i = 0; i < _pic.length; i++) {
        localPic.add(dio.MultipartFile.fromFileSync(_pic[i].path,
            filename: 'pic$i.jpg', contentType: MediaType('image', 'jpg')));
      }
      var data = dio.FormData.fromMap({
        "notification_id": widget.data["_id"],
        "text": _answerText.text,
        "photos": localPic,
      });
      NotificationsAPI().homeworkAnswer(data).then((res) {
        if (res['error'] == false) {
          _btnController.success();
        } else {
          _btnController.error();
        }
      });
    } else {
      EasyLoading.showError('havToAns'.tr);
    }
    _btnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: Text('ansHomework'.tr)),
            ),
            const Divider(),
            Center(
              child: Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 350),
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: TextFormField(
                  controller: _answerText,
                  style: const TextStyle(
                    color: MyColor.grayDark,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                      //contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      contentPadding: const EdgeInsets.all(12.0),
                      hintText: 'wrAnsHere'.tr,
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
                ),
              ),
            ),
            const Divider(),
            _pic.isNotEmpty
                ? Container(
                    padding:
                        const EdgeInsets.only(right: 20, left: 20, top: 40),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (XFile img in _pic) _imageListView(img),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
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
                : _buttons('uImg'.tr, pickImage1, LineIcons.image, true),
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

  _imageListView(XFile img) {
    return Container(
      height: 150,
      width: Get.width / 4,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: MyColor.white3),
        borderRadius: const BorderRadius.all(Radius.circular(11)),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          //show  XFile image
          child: Image.file(
            File(img.path),
            fit: BoxFit.cover,
          )),
    );
  }
}
