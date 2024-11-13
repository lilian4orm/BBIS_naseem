import 'dart:io';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart' as dio;
import 'package:restart_app/restart_app.dart';
import 'package:BBInaseem/screens/auth/accounts_screen.dart';
import 'package:BBInaseem/screens/auth/login_page.dart';
import '../../api_connection/auth_connection.dart';
import '../../api_connection/student/api_profile.dart';
import '../../local_database/models/account.dart';
import '../../provider/accounts_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/teacher/provider_teacher_dashboard.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_features_message.dart';
import '../../static_files/my_loading.dart';
import '../../static_files/my_random.dart';
import '../../static_files/my_url.dart';
import '../auth/connect_us.dart';

import 'driver_student/driver_student.dart';
import 'package:http_parser/http_parser.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'map_track/driver_map.dart';
import 'notifications/notification.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePageDriver extends StatefulWidget {
  final Map userData;
  const HomePageDriver({super.key, required this.userData});
  @override
  _HomePageDriverState createState() => _HomePageDriverState();
}

class _HomePageDriverState extends State<HomePageDriver> {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  late IO.Socket socket;
  final AccountProvider accountProvider = Get.put(AccountProvider());
  TokenProvider get tokenProvider => Get.put(TokenProvider());

  initSocket() {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    socket = IO.io(
        '${socketURL}driver',
        IO.OptionBuilder()
            .disableAutoConnect()
            .setTransports(['websocket'])
            .setAuth(headers)
            .build());
  }

  pickImage() async {
    EasyLoading.show(status: 'loading'.tr);
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
            EasyLoading.showSuccess('changeImgSuccess'.tr);
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
            content: Text('reloadApp'.tr),
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

  Future<XFile?> compressAndGetFile(File file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, "$targetPath/img_$getRand.jpg",
        quality: 40);
    return result;
  }

  @override
  void initState() {
    Permission.location.isDenied.then((value) {
      if (value) {
        Permission.location.request();
      }
    });
    Auth().getStudentInfo();
    initSocket();
    //   await FirebaseMessaging.instance
    //       .subscribeToTopic("school_${res['account_school']}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        title: Text(
          "driver".tr,
          style: const TextStyle(color: MyColor.purple),
        ),
        iconTheme: const IconThemeData(
          color: MyColor.purple,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'logout'.tr,
                content: Text(
                  'confirmLogout'.tr,
                ),
                // onCancel: ()=>print("fv"),
                // onConfirm: ()=>print("fv"),
                // textCancel: "الغاء",
                // textConfirm: "تأكيد",
                // cancelTextColor: MyColor.c5,
                // confirmTextColor: MyColor.c5,
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
                          Get.delete<TeacherDashboardProvider>();
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
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_rounded),
            onPressed: () {
              Get.to(() => const AccountsScreen());
            },
          ),
        ],
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: GetBuilder<MainDataGetProvider>(builder: (_) {
            return Column(
              children: [
                _.mainData.isEmpty
                    ? loading()
                    : Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    "driver".tr,
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
                                _.mainData.isEmpty
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10.0)),
                                          child: Image.asset(
                                              "assets/img/graduated.png"),
                                        ),
                                      )
                                    : _.mainData['account']['account_img'] ==
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
                                                imageUrl: _.contentUrl +
                                                    _.mainData['account']
                                                        ['account_img'],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                  ],
                                                ),
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
                const Divider(
                  thickness: 1,
                  color: MyColor.purple,
                ),
                _.mainData.isEmpty
                    ? loading()
                    : GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        physics: const BouncingScrollPhysics(),
                        childAspectRatio: 1.1,
                        padding: const EdgeInsets.only(top: 15),
                        mainAxisSpacing: 20.0,
                        crossAxisSpacing: 20.0,
                        //_.mainData['account']['school']['school_features']['features_absence']
                        children: [
                          _gridContainer(
                              "students".tr,
                              "assets/img/dashboard/d-bus.png",
                              const DriverStudent(),
                              _.mainData['account']['school']['school_features']
                                  ['features_drivers']),
                          _gridContainer(
                              "notification".tr,
                              "assets/img/dashboard/d-notification.png",
                              const NotificationByType(
                                notificationType: "تبليغ",
                              ),
                              _.mainData['account']['school']['school_features']
                                  ['features_notifications']),
                          _gridContainer(
                              'map'.tr,
                              "assets/img/dashboard/d-map.png",
                              DriversMap(socket: socket),
                              _.mainData['account']['school']['school_features']
                                  ['features_gps']),
                          _gridContainer(
                              "school".tr,
                              "assets/img/dashboard/d-contact.png",
                              const ConnectUs(),
                              true),
                        ],
                      ),
              ],
            );
          }),
        ),
      ),
    );
  }

  _gridContainer(t, img, Widget nav, bool features) {
    return GestureDetector(
      onTap: () {
        if (features) {
          Get.to(() => nav);
        } else {
          featureAttention();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: MyColor.purple, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.only(right: 25, left: 25, top: 25),
                child: Image.asset(
                  img,
                  height: 40,
                  color: MyColor.purple,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(5),
                child: AutoSizeText(
                  t,
                  maxLines: 1,
                  minFontSize: 12,
                  maxFontSize: 25,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: MyColor.purple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
