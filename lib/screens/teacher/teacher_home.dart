import 'package:BBInaseem/screens/auth/accounts_screen.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../../api_connection/auth_connection.dart';
import '../../api_connection/student/api_dashboard_data.dart';
import '../../api_connection/student/api_profile.dart';

import '../../provider/auth_provider.dart';
import '../../provider/student/student_provider.dart';
import '../../provider/teacher/chat/chat_socket.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_package_info.dart';
import '../../static_files/my_random.dart';
import 'chat/chat_main/chat_main.dart';
import 'pages/degree/degree_choice.dart';
import 'pages/exam_schedule.dart';
import 'pages/notifications/notification_all.dart';
import 'pages/show_latest_news.dart';
import 'pages/teacher_attend.dart';
import 'pages/teacher_salary/teacher_salary.dart';
import 'pages/teacher_weekly_schedule.dart';
import 'profile.dart';

class HomePageTeacher extends StatefulWidget {
  final Map userData;
  const HomePageTeacher({super.key, required this.userData});
  @override
  _HomePageTeacherState createState() => _HomePageTeacherState();
}

class _HomePageTeacherState extends State<HomePageTeacher> {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  final LatestNewsProvider latestNewsProvider = Get.put(LatestNewsProvider());

  pickImage() async {
    EasyLoading.show(status: "loading".tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      XFile file = XFile(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) {
        dio.FormData dataInfo = dio.FormData.fromMap({
          "account_img": dio.MultipartFile.fromFileSync(value!.path,
              filename: 'pic.jpg', contentType: MediaType('image', 'jpg')),
          "account_img_old": Get.put(MainDataGetProvider()).mainData['account']
              ['account_img']
        });
        StudentProfileAPI().editImgProfile(dataInfo).then((res) async {
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

  Future<XFile?> compressAndGetFile(XFile file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.path, "$targetPath/img_$getRand.jpg",
        quality: 40);
    return result;
  }

  initUserData() async {
    await Auth().getStudentInfo();
    Get.put(ChatSocketProvider()).changeSocket(dataProvider);
  }

  @override
  void initState() {
    initUserData();

    // StudentAPI().getStudentInfo().then((res) async {
    //   await FirebaseMessaging.instance
    //       .subscribeToTopic("school_${res['account_school']}");
    // });
    DashboardDataAPI().latestNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColor.yellow,
          title: Text(
            widget.userData['account_name'].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: MyColor.purple),
          ),
          leading: GetBuilder<MainDataGetProvider>(builder: (val) {
            return GestureDetector(
              onTap: () {
                pickImage();
              },
              child: val.mainData.isEmpty
                  ? Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1.5, color: MyColor.purple),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          shape: BoxShape.rectangle),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        child: Image.asset("assets/img/graduated.png"),
                      ),
                    )
                  : val.mainData['account']['account_img'] == null
                      ? Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: MyColor.purple),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              shape: BoxShape.rectangle),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            child: Image.asset("assets/img/graduated.png"),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: MyColor.purple),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              shape: BoxShape.rectangle),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            child: CachedNetworkImage(
                              imageUrl: val.contentUrl +
                                  val.mainData['account']['account_img'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
            );
          }),
          //_.mainData.isEmpty ? Container() : _header(_.mainData, _.contentUrl),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: MyColor.purple,
              ),
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
                      Auth().loginOut().then((res) {
                        if (res['error'] == false) {
                          EasyLoading.showSuccess(res['message'].toString());
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
              icon: const Icon(
                Icons.info_outline,
                color: MyColor.white0,
              ),
              onPressed: () {
                Get.defaultDialog(
                  title: "version".tr,
                  content: FutureBuilder<String>(
                    future: packageInfo(), // async work
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Text('loading'.tr);
                        default:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, left: 20),
                              child: RichText(
                                text: TextSpan(
                                    text: "version".tr,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 17),
                                    children: <TextSpan>[
                                      const TextSpan(
                                        text: " : ",
                                        style: TextStyle(
                                            color: MyColor.purple,
                                            fontSize: 17),
                                      ),
                                      TextSpan(
                                        text: '${snapshot.data}',
                                        style: const TextStyle(
                                            color: MyColor.purple,
                                            fontSize: 17),
                                      ),
                                    ]),
                              ),
                            );
                          }
                      }
                    },
                  ),
                  cancel: MaterialButton(
                    color: MyColor.purple,
                    onPressed: () => Get.back(),
                    child: Text(
                      "done".tr,
                      style: const TextStyle(color: MyColor.yellow),
                    ),
                  ),
                );
              },
            )
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: GetBuilder<MainDataGetProvider>(
                builder: (_) => SingleChildScrollView(
                      child: Column(
                        children: [
                          GetBuilder<LatestNewsProvider>(
                              builder: (con) => con.newsData.isEmpty
                                  ? Container()
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                          'latestNews'.tr,
                                          style: const TextStyle(
                                              color: MyColor.black,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          height: Get.height / 4.5,
                                          child: Swiper(
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: InkWell(
                                                  onTap: () {
                                                    Get.to(() => ShowLatestNews(
                                                          data: con
                                                              .newsData[index],
                                                          //tag: _data.newsData[index]['latest_news_img'],
                                                        ));
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      Positioned.fill(
                                                          child: Image.asset(
                                                              "assets/img/t1.png",
                                                              fit:
                                                                  BoxFit.fill)),
                                                      con.newsData[index][
                                                                  'latest_news_title'] ==
                                                              null
                                                          ? Container()
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      SizedBox(
                                                                          width:
                                                                              120,
                                                                          child:
                                                                              Text(
                                                                            con.newsData[index]['latest_news_title'],
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                          ))),
                                                            )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            loop: false,
                                            itemCount: con.newsData.length,
                                            viewportFraction: 0.9,
                                            scale: 0.9,
                                          ),
                                        ),
                                      ],
                                    )),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //   children: [
                          //     _buttons("المستمسكات", const AttachDocuments(),
                          //         LineIcons.upload),
                          //     _buttons("السيرة الذاتية", null,
                          //         LineIcons.fileInvoice),
                          //   ],
                          // ),
                          const Divider(
                            thickness: 1,
                            color: MyColor.purple,
                          ),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            physics: const BouncingScrollPhysics(),
                            childAspectRatio: 1.1,
                            padding: const EdgeInsets.only(top: 15),
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            children: [
                              ///Announcement()
                              _gridContainer(
                                  "chat".tr,
                                  "assets/img/dashboard/d-notification.png",
                                  const ChatMain()),

                              ///Salary()
                              _gridContainer(
                                  "salary".tr,
                                  "assets/img/dashboard/salary.png",
                                  const TeacherSalary()),

                              ///TeacherAttend(userData: widget.userData)
                              _gridContainer(
                                  "com".tr,
                                  "assets/img/dashboard/Attendees.png",
                                  TeacherAttend(userData: widget.userData)),

                              ///ShowNotification()
                              _gridContainer(
                                  "notification".tr,
                                  "assets/img/dashboard/s-notification.png",
                                  NotificationTeacherAll(
                                    userData: widget.userData,
                                  )),

                              ///ExamTable()
                              _gridContainer(
                                  'examTable'.tr,
                                  "assets/img/dashboard/s-table.png",
                                  const TeacherExamSchedule()), //s-notification
                              ///ELearning()
                              //   _gridContainer("الحضور الالكتروني", "assets/img/dashboard/live.png", const LiveEducation()),

                              ///DegreeList(()
                              _gridContainer(
                                  'degrees'.tr,
                                  "assets/img/dashboard/marks2.png",
                                  const DegreeChoice()),

                              ///StudyTable()
                              _gridContainer(
                                  'weeklyTable'.tr,
                                  "assets/img/dashboard/s-tables.png",
                                  const TeacherWeeklySchedule()),

                              ///HomeWork()
                              _gridContainer(
                                  'acounts'.tr,
                                  "assets/img/graduated.png",
                                  TeacherProfile(
                                    userData: widget.userData,
                                  )),

                              _gridContainer(
                                  'addAcount'.tr,
                                  "assets/img/dashboard/images.png",
                                  const AccountsScreen()),
                            ],
                          ),
                          const SizedBox(height: 30)
                        ],
                      ),
                    )),
          ),
        ));
  }

  Widget _gridContainer(t, img, Widget nav) {
    return GestureDetector(
      onTap: () {
        Get.to(() => nav);
      },
      child: Container(
        decoration: BoxDecoration(
            color: MyColor.yellow,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: MyColor.grayDark,
                blurRadius: .5,
                spreadRadius: .2,
              )
            ]),
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

  Widget buttons(t, Widget? nav, icon) {
    return SizedBox(
      width: Get.width / 2.5,
      child: MaterialButton(
          color: MyColor.purple,
          textColor: MyColor.yellow,
          elevation: 0,
          onPressed: () {
            if (nav != null) {
              Get.to(() => nav);
            }
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            children: [
              AutoSizeText(
                t,
                maxFontSize: 14,
                minFontSize: 11,
                maxLines: 1,
              ),
              const Spacer(),
              Icon(
                icon,
                color: MyColor.yellow,
              )
            ],
          )),
    );
  }

  Widget header1(Map data, String contentUrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AutoSizeText(
                  "الاستاذ",
                  maxLines: 1,
                  minFontSize: 15,
                  maxFontSize: 20,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
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
              data.isEmpty
                  ? Container(
                      width: Get.width / 4,
                      height: Get.width / 4,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1.5, color: MyColor.purple),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          shape: BoxShape.rectangle),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        child: Image.asset("assets/img/graduated.png"),
                      ),
                    )
                  : data['account']['account_img'] == null
                      ? Container(
                          width: Get.width / 4,
                          height: Get.width / 4,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: MyColor.purple),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              shape: BoxShape.rectangle),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            child: Image.asset("assets/img/graduated.png"),
                          ),
                        )
                      : Container(
                          width: Get.width / 4,
                          height: Get.width / 4,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1.5, color: MyColor.purple),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              shape: BoxShape.rectangle),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            child: CachedNetworkImage(
                              imageUrl:
                                  contentUrl + data['account']['account_img'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
              TextButton(
                onPressed: () {
                  pickImage();
                },
                child: const AutoSizeText(
                  "تغيير الصورة",
                  maxLines: 1,
                  minFontSize: 15,
                  maxFontSize: 20,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: MyColor.purple, fontSize: 18),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
