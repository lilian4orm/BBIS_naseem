import 'package:BBInaseem/provider/accounts_provider.dart';
import 'package:BBInaseem/provider/locale_controller.dart';
import 'package:BBInaseem/screens/auth/accounts_screen.dart';
import 'package:BBInaseem/screens/auth/login_page.dart';
import 'package:BBInaseem/screens/student/profile/edit_profile.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as p;
import 'package:restart_app/restart_app.dart';

import '../../../api_connection/auth_connection.dart';
import '../../../api_connection/student/api_profile.dart';
import '../../../local_database/models/account.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/provider_student_dashboard.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import '../../../static_files/my_package_info.dart';
import '../../../static_files/my_random.dart';
import '../../../static_files/my_times.dart';
import 'attach_documents.dart';

class StudentProfile extends StatefulWidget {
  final Map userData;

  const StudentProfile({super.key, required this.userData});

  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _zoomName = TextEditingController();
  final _formCheck = GlobalKey<FormState>();
  final AccountProvider accountProvider = Get.put(AccountProvider());
  TokenProvider get tokenProvider => Get.put(TokenProvider());
  MylocaleController localController = Get.put(MylocaleController());
  final box = GetStorage();

  @override
  bool get wantKeepAlive => true;

  onOtherAccountFound(Map<String, dynamic> account) async {
    await accountProvider.onClickAccount(account);
    tokenProvider.addToken(account);
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (!isIOS) {
      Restart.restartApp();
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('confirm'.tr),
            content: Text(
              'reloadApp'.tr,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () {
                  Restart.restartApp();
                },
                child: Text('confirm'.tr),
              ),
            ],
          );
        },
      );
    }
  }

  pickImage() async {
    EasyLoading.show(status: 'getdata'.tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      XFile file = XFile(result.files.single.path!);
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
            EasyLoading.showSuccess("تم تغيير الصورة بنجاح");
          } else {
            EasyLoading.showError("يوجد خطأ ما");
          }
        });
        EasyLoading.dismiss();
      });
    } else {
      EasyLoading.dismiss();
      // User canceled the picker
    }
  }

  Future<XFile?> compressAndGetFile(XFile file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, "$targetPath/img_$getRand.jpg",
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
          //  Map _data = {"account_zoom": _zoomName.text};
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
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Get.defaultDialog(
                  title: 'logout'.tr,
                  content: Text(
                    'confirmLogout'.tr,
                  ),
                  cancel: MaterialButton(
                    color: MyColor.purple,
                    onPressed: () => Get.back(),
                    child: Text(
                      "cancel".tr,
                      style: const TextStyle(color: MyColor.yellow),
                    ),
                  ),
                  confirm: MaterialButton(
                    color: MyColor.red,
                    onPressed: () {
                      Auth().loginOut().then((res) async {
                        if (res['error'] == false) {
                          Account accountToDelete = Account.fromMap(
                              Map<String, dynamic>.from(widget.userData));

                          await accountProvider.deleteAccount(accountToDelete);

                          if (accountProvider.accounts.firstOrNull != null) {
                            onOtherAccountFound(
                                accountProvider.accounts.first.toMap());
                          } else {
                            Get.offAll(() => const LoginPage());
                            Get.delete<StudentDashboardProvider>();
                            FlutterAppBadger.removeBadge();
                            EasyLoading.showSuccess(res['message'].toString());
                          }
                        } else {
                          EasyLoading.showError(res['message'].toString());
                        }
                      });
                    },
                    child: Text(
                      "confirm".tr,
                      style: const TextStyle(color: MyColor.white1),
                    ),
                  ),
                );
              },
            )
          ],
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                shape: BoxShape.rectangle),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                child: GetBuilder<MainDataGetProvider>(builder: (val) {
                  return val.mainData.isEmpty
                      ? Image.asset(
                          'assets/img/logo.png',
                          fit: BoxFit.fill,
                        )
                      : CachedNetworkImage(
                          imageUrl: val.contentUrl +
                              val.mainData['account']['school']['school_logo'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/img/logo.png',
                            fit: BoxFit.fill,
                          ),
                        );
                })),
          ),
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
                                  "student".tr,
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
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (val.mainData['account']["account_division_current"]
                            ['class_name'] !=
                        null)
                      _text(
                          "class".tr,
                          val.mainData['account']["account_division_current"]
                              ['class_name']),
                    _text(
                        'sec'.tr,
                        val.mainData['account']["account_division_current"]
                            ['leader']),
                    _text('school'.tr,
                        val.mainData['account']['school']['school_name']),
                    const SizedBox(height: 10),
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
                                      color: MyColor.yellow,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.userData['account_birthday'] != null)
                              _text(
                                  "birth".tr,
                                  fromISOToDate(
                                      widget.userData['account_birthday'])),
                            if (widget.userData['account_mobile'] != null)
                              _text("phone".tr,
                                  widget.userData['account_mobile'].toString()),
                          ],
                        ),
                        TextButton(
                          onPressed: _navToEditProfile,
                          child: Container(
                              height: 40,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyColor.yellow,
                              ),
                              child: Center(child: Text('edit'.tr))),
                        )
                      ],
                    ),

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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (box.read('language') == 'en') {
                              localController.changeLanguage('ar');
                            } else {
                              localController.changeLanguage('en');
                            }
                          },
                          child: Container(
                              width: Get.width / 2.5,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: MyColor.yellow)),
                              child: Row(
                                children: [
                                  AutoSizeText(
                                    'changeLanguage'.tr,
                                    maxFontSize: 14,
                                    minFontSize: 11,
                                    maxLines: 1,
                                    style:
                                        const TextStyle(color: MyColor.purple),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.language,
                                    color: MyColor.purple,
                                  )
                                ],
                              )),
                        ),
                        const SizedBox(height: 8),

                        ///AttachDocuments()
                        _buttons("Documents".tr, const AttachDocuments(),
                            LineIcons.upload, true),
                        const SizedBox(height: 8),
                        _buttons("addAcount".tr, const AccountsScreen(),
                            LineIcons.fileInvoice, true),
                        const SizedBox(height: 8),

                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('confirm'.tr),
                                    content: Text('deleteConfirm'.tr),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('cancel'.tr),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          EasyLoading.show(
                                              status: 'loading'.tr);
                                          StudentProfileAPI()
                                              .deleteAcount()
                                              .then((res) async {
                                            EasyLoading.dismiss();
                                            Auth().redirect();
                                            //Navigator.of(context).pop();
                                            EasyLoading.showInfo(
                                                res['message'].toString());
                                          });

                                          // EasyLoading.dismiss();
                                          // Auth().redirect();
                                        },
                                        child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text('confirm'.tr)),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: Container(
                              width: Get.width / 2.4,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(color: MyColor.red)),
                              child: Row(
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'deleteAcount'.tr,
                                      style:
                                          const TextStyle(color: MyColor.red),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.delete,
                                    color: MyColor.red,
                                  )
                                ],
                              )),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          height: 30,
                        ),

                        ///ConnectUs()
                        // _buttons("call the school", ConnectUs(), LineIcons.buildingAlt,true),
                        // ///Reports()
                        // _buttons("reports", Reports(), LineIcons.fileInvoice,true),
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
                Get.to(() => nav);
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

  void _navToEditProfile() {
    Get.to(() => EditProfile(
          userData: widget.userData,
        ))?.then((value) {
      setState(() {});
    });
  }
}
