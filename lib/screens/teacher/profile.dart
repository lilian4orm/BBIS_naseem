import 'dart:io';

import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:BBInaseem/provider/locale_controller.dart';
import 'package:BBInaseem/screens/auth/accounts_screen.dart';

import '../../../api_connection/auth_connection.dart';
import '../../../api_connection/student/api_profile.dart';
import '../../../provider/auth_provider.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import '../../../static_files/my_package_info.dart';
import '../../../static_files/my_random.dart';
import '../../../static_files/my_times.dart';
import '../student/profile/attach_documents.dart';

class TeacherProfile extends StatefulWidget {
  final Map userData;
  const TeacherProfile({super.key, required this.userData});

  @override
  _TeacherProfileState createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _zoomName = TextEditingController();
  final _formCheck = GlobalKey<FormState>();
  MylocaleController localController = Get.put(MylocaleController());
  final box = GetStorage();

  @override
  bool get wantKeepAlive => true;

  pickImage() async {
    EasyLoading.show(status: 'getdata'.tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) {
        dio.FormData data = dio.FormData.fromMap({
          "account_img": dio.MultipartFile.fromFileSync(value!.path,
              filename: 'pic.jpg', contentType: MediaType('image', 'jpg')),
          "account_img_old": Get.put(MainDataGetProvider()).mainData['account']
              ['account_img']
        });
        StudentProfileAPI().editImgProfile(data).then((res) async {
          if (res['error'] == false) {
            await Auth().getStudentInfo();
            EasyLoading.showSuccess('imgChange'.tr);
          } else {
            EasyLoading.showError('errorFound'.tr);
          }
        });
        EasyLoading.dismiss();
      });
    } else {
      EasyLoading.dismiss();
      // User canceled the picker
    }
  }

  Future<XFile?> compressAndGetFile(File file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, "$targetPath/img_$getRand.jpg",
        quality: 40);
    return result;
  }

  _showAddZoom() {
    Get.defaultDialog(
      title: 'zoomName'.tr,
      content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formCheck,
            child: TextFormField(
              controller: _zoomName,
              style: const TextStyle(
                color: MyColor.grayDark,
              ),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  //hintText: tr("name"),
                  errorStyle: const TextStyle(color: MyColor.red),
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
                      color: MyColor.grayDark,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: MyColor.grayDark,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: const BorderSide(
                      color: MyColor.grayDark,
                    ),
                  ),
                  prefixIcon: const Icon(LineIcons.video),
                  filled: true
                  //fillColor: Colors.green
                  ),
              // validator: (value) {
              //   var result = value.length < 3 ? tr("fillText") : null;
              //   return result;
              // },
            ),
          )),
      // onCancel: ()=>print("fv"),
      // onConfirm: ()=>print("fv"),
      // textCancel: "الغاء",
      // textConfirm: "تأكيد",
      // cancelTextColor: MyColor.c5,
      // confirmTextColor: MyColor.c5,

      confirm: MaterialButton(
        color: MyColor.red,
        onPressed: () {
          //  Map data = {"account_zoom": _zoomName.text};
          if (_formCheck.currentState!.validate()) {
            // StudentAPI().addZoomName(_data).then((res) async {
            //   if (res['error'] == false) {
            //     await StudentAPI().getStudentInfo();
            //     Get.back();
            //     EasyLoading.showSuccess(res['results'].toString());
            //   } else {
            //     EasyLoading.showError(res['results'].toString());
            //   }
            // });
          }
        },
        child: Text(
          'confirm'.tr,
          style: const TextStyle(color: MyColor.white1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColor.yellow,
          title: Text(
            "personalFile".tr,
            style: const TextStyle(color: MyColor.purple),
          ),
          iconTheme: const IconThemeData(
            color: MyColor.purple,
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  shape: BoxShape.rectangle),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: GetBuilder<MainDataGetProvider>(builder: (val) {
                    return val.mainData.isEmpty
                        ? Container()
                        : CachedNetworkImage(
                            imageUrl: val.contentUrl +
                                val.mainData['account']['school']
                                    ['school_logo'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          );
                  })),
            ),
          ],
          // leading:
        ),
        body: GetBuilder<MainDataGetProvider>(builder: (val) {
          return val.mainData.isEmpty
              ? loading()
              : ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  "teacher".tr,
                                  maxLines: 1,
                                  minFontSize: 15,
                                  maxFontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: MyColor.black),
                                ),
                                AutoSizeText(
                                  widget.userData['account_name'].toString(),
                                  maxLines: 1,
                                  minFontSize: 15,
                                  maxFontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: MyColor.purple),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              val.mainData.isEmpty
                                  ? Container(
                                      width: Get.width / 4,
                                      height: Get.width / 4,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.5,
                                              color: MyColor.purple),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10.0)),
                                          shape: BoxShape.rectangle),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0)),
                                        child: Image.asset(
                                            "assets/img/graduated.png"),
                                      ),
                                    )
                                  : val.mainData['account']['account_img'] ==
                                          null
                                      ? Container(
                                          width: Get.width / 4,
                                          height: Get.width / 4,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1.5,
                                                  color: MyColor.purple),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10.0)),
                                              shape: BoxShape.rectangle),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10.0)),
                                            child: Image.asset(
                                                "assets/img/graduated.png"),
                                          ),
                                        )
                                      : Container(
                                          width: Get.width / 4,
                                          height: Get.width / 4,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1.5,
                                                  color: MyColor.purple),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10.0)),
                                              shape: BoxShape.rectangle),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10.0)),
                                            child: CachedNetworkImage(
                                              imageUrl: val.contentUrl +
                                                  val.mainData['account']
                                                      ['account_img'],
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                              TextButton(
                                onPressed: () {
                                  pickImage();
                                },
                                child: AutoSizeText(
                                  'editImg'.tr,
                                  maxLines: 1,
                                  minFontSize: 15,
                                  maxFontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: MyColor.purple, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (val.mainData['account']['account_zoom'] != null)
                      _text('zoomAcount'.tr,
                          val.mainData['account']['account_zoom'].toString()),
                    if (val.mainData['account']['account_zoom'] == null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: GestureDetector(
                              onTap: () {
                                _showAddZoom();
                                // Get.to(() => _nav);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(color: MyColor.yellow)),
                                child: Row(
                                  children: [
                                    AutoSizeText(
                                      'zoomAdd'.tr,
                                      maxFontSize: 14,
                                      minFontSize: 11,
                                      maxLines: 1,
                                      style: const TextStyle(
                                          color: MyColor.purple),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      LineIcons.video,
                                      color: MyColor.purple,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.userData['account_birthday'] != null)
                      _text("birth".tr,
                          fromISOToDate(widget.userData['account_birthday'])),
                    if (widget.userData['account_mobile'] != null)
                      _text("phone".tr,
                          widget.userData['account_mobile'].toString()),
                    _text("email".tr,
                        widget.userData['account_email'].toString()),
                    FutureBuilder<String>(
                      future: packageInfo(), // async work
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Text('Loading....');
                          default:
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return _text("version".tr, '${snapshot.data}');
                            }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        // GestureDetector(
                        //   onTap: () {
                        //     if (box.read('language') == 'en') {
                        //       localController.changeLanguage('ar');
                        //     } else {
                        //       localController.changeLanguage('en');
                        //     }
                        //   },
                        //   child: Container(
                        //       width: Get.width / 2.5,
                        //       padding: const EdgeInsets.all(8),
                        //       decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(5.0),
                        //           border: Border.all(color: MyColor.yellow)),
                        //       child: Row(
                        //         children: [
                        //           AutoSizeText(
                        //             'changeLanguage'.tr,
                        //             maxFontSize: 14,
                        //             minFontSize: 11,
                        //             maxLines: 1,
                        //             style:
                        //                 const TextStyle(color: MyColor.purple),
                        //           ),
                        //           const Spacer(),
                        //           const Icon(
                        //             Icons.language,
                        //             color: MyColor.purple,
                        //           )
                        //         ],
                        //       )),
                        // ),

                        const SizedBox(height: 10),
                        _buttons("Documents".tr, const AttachDocuments(),
                            LineIcons.upload, true),
                        const SizedBox(height: 10),
                        _buttons2("addAcount".tr, const AccountsScreen(),
                            LineIcons.fileInvoice, true),
                      ],
                    ),
                    // Container(
                    //   padding: const EdgeInsets.only(right: 20, left: 20),
                    //   child: _buttonsSession("activeSession", ActiveSession()),
                    // )
                  ],
                );
        }));
  }

  _buttons(t, Widget nav, icon, bool enable) {
    return SizedBox(
      width: Get.width / 2.5,
      child: GestureDetector(
        onTap: enable
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttachDocuments()),
                );
              }
            : null,
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: MyColor.yellow)),
            child: Row(
              children: [
                AutoSizeText(
                  t,
                  maxFontSize: 14,
                  minFontSize: 11,
                  maxLines: 1,
                  style: const TextStyle(color: MyColor.purple),
                ),
                const Spacer(),
                Icon(
                  icon,
                  color: MyColor.purple,
                )
              ],
            )),
      ),
    );
  }

  _buttons2(t, Widget nav, icon, bool enable) {
    return SizedBox(
      width: Get.width / 2.5,
      child: GestureDetector(
        onTap: enable
            ? () {
                Get.to(() => const AccountsScreen());
              }
            : null,
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: MyColor.yellow)),
            child: Row(
              children: [
                AutoSizeText(
                  t,
                  maxFontSize: 14,
                  minFontSize: 11,
                  maxLines: 1,
                  style: const TextStyle(color: MyColor.purple),
                ),
                const Spacer(),
                Icon(
                  icon,
                  color: MyColor.purple,
                )
              ],
            )),
      ),
    );
  }

  _buttonsSession(t, Widget nav) {
    return SizedBox(
      width: Get.width / 2.5,
      child: MaterialButton(
        color: MyColor.purple,
        elevation: 0,
        onPressed: () {
          Get.to(() => nav);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: AutoSizeText(
          t,
          maxFontSize: 14,
          minFontSize: 11,
          maxLines: 1,
          style: const TextStyle(color: MyColor.yellow),
        ),
      ),
    );
  }

  _text(String first, String second) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20),
      child: RichText(
        text: TextSpan(
            text: first,
            style: const TextStyle(color: Colors.black, fontSize: 17),
            children: <TextSpan>[
              const TextSpan(
                text: " : ",
                style: TextStyle(color: MyColor.purple, fontSize: 17),
              ),
              TextSpan(
                text: second,
                style: const TextStyle(color: MyColor.purple, fontSize: 17),
              ),
            ]),
      ),
    );
  }
}
