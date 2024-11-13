import 'package:BBInaseem/main.dart';
import 'package:BBInaseem/screens/student/dashboard_student/food_schedule.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:BBInaseem/screens/student/dashboard_student/monthly_message.dart';
import '../../../api_connection/student/api_dashboard_data.dart';
import '../../../api_connection/student/api_notification.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/provider_notification.dart';
import '../../../provider/student/student_provider.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_features_message.dart';
import '../../../static_files/my_loading.dart';
import 'chat/chat_main/chat_main.dart';
import 'exam_degree.dart';
import 'exam_schedule.dart';
import 'homeworks.dart';
import 'notification_all.dart';
import 'show/show_latest_news.dart';
import 'student_attend.dart';
import 'student_ride/student_ride.dart';
import 'student_salary/student_salary.dart';
import 'weekly_schedule.dart';

class Dashboard extends StatefulWidget {
  final Map userData;
  const Dashboard({super.key, required this.userData});
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  // int _latestNewsCurrentIndex = 0;

  _getStudentInfo() async {
    Map data = {
      "study_year": Get.put(MainDataGetProvider()).mainData['setting'][0]
          ['setting_year'],
      "page": 0,
      "class_school": Get.put(MainDataGetProvider()).mainData['account']
          ['account_division_current']['_id'],
      "type": null,
    };
    await NotificationsAPI().getNotifications(data);
  }

  @override
  void initState() {
    super.initState();
    _getStudentInfo();

    DashboardDataAPI().latestNews();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 16, left: 16),
                child: Row(
                  children: [
                    GetBuilder<MainDataGetProvider>(
                        builder: (mainDataProvider) {
                      return Container(
                        width: 55,
                        height: 55,
                        // padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            shape: BoxShape.rectangle),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                            child: CachedNetworkImage(
                              imageUrl: mainDataProvider.contentUrl +
                                  mainDataProvider.mainData["account"]['school']
                                      ['school_logo'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/img/logo.png',
                                fit: BoxFit.fill,
                              ),
                            )),
                      );
                    }),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sharePref.getString('guest') == 'guest'
                              ? 'guest'.tr
                              : widget.userData['account_name'].toString(),
                          style: const TextStyle(
                              color: MyColor.purple,
                              fontWeight: FontWeight.bold),
                        ),
                        GetBuilder<MainDataGetProvider>(
                            builder: (mainDataProvider) =>
                                sharePref.getString('guest') == 'guest'
                                    ? const Text("")
                                    : mainDataProvider.mainData.isEmpty
                                        ? const Text("")
                                        : Text(
                                            "${mainDataProvider.mainData['account']['account_division_current']['class_name']} - ${mainDataProvider.mainData['account']['account_division_current']['leader']}",
                                            style: const TextStyle(
                                                color: MyColor.purple,
                                                fontWeight: FontWeight.bold,
                                                height: 1.5),
                                          )),
                      ],
                    ),
                    const Spacer(),
                    GetBuilder<NotificationProvider>(builder: (countNumber) {
                      FlutterAppBadger.updateBadgeCount(
                          countNumber.countUnread);
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => NotificationAll(
                                userData: widget.userData,
                              ));
                        },
                        child: Container(
                            child: countNumber.countUnread == 0
                                ? SvgPicture.asset(
                                    'assets/img/noitifcations.svg',
                                    height: 40,
                                  )
                                : Stack(
                                    children: <Widget>[
                                      SvgPicture.asset(
                                        'assets/img/noitifcations.svg',
                                        height: 40,
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(1),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 12,
                                            minHeight: 12,
                                          ),
                                          child: Text(
                                            countNumber.countUnread.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                      );
                    })
                  ],
                ),
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              GetBuilder<LatestNewsProvider>(
                  builder: (data) =>
                      // data.newsData.isEmpty
                      //     ? Container()
                      //     :
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'latestNews'.tr,
                            style: const TextStyle(
                                color: MyColor.black, fontSize: 20),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          SizedBox(
                            height: Get.height / 4.5,
                            child: Swiper(
                              itemBuilder: (BuildContext context, int index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => ShowLatestNews(
                                            data: data.newsData[index],
                                            //tag: _data.newsData[index]['latest_news_img'],
                                          ));
                                    },
                                    child: Stack(
                                      children: [
                                        Center(
                                            child: Image.asset(
                                                "assets/img/t1.png",
                                                width: double.infinity,
                                                fit: BoxFit.cover)),
                                        data.newsData[index]
                                                    ['latest_news_title'] ==
                                                null
                                            ? Container()
                                            : Align(
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      left: 10,
                                                    ),
                                                    width: 120,
                                                    child: Text(
                                                      data.newsData[index]
                                                          ['latest_news_title'],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )))
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loop: false,
                              itemCount: data.newsData.length,
                              viewportFraction: .85,
                              scale: 0.9,
                            ),
                          ),
                        ],
                      )),
              const SizedBox(height: 10),
              Text(
                'main'.tr,
                style: const TextStyle(color: MyColor.black, fontSize: 20),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _container('work'.tr, 'hose'.tr, "assets/img/books.png",
                      const HomeWork(), Get.width),
                  _container('sech'.tr, 'week'.tr, "assets/img/inspiration.png",
                      const WeeklySchedule(), Get.width),
                  // _container("الواجبات اليومية", "assets/img/books.png", HomeWork(), Get.width),
                  // _container("التعليم الالكتروني", "assets/img/inspiration.png", ELearning(), Get.width),
                ],
              ),
              GetBuilder<MainDataGetProvider>(builder: (val) {
                return val.mainData.isEmpty
                    ? loading()
                    : AnimationLimiter(
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          physics: const BouncingScrollPhysics(),
                          childAspectRatio: 1.2,
                          padding:
                              const EdgeInsets.only(top: 15, left: 6, right: 6),
                          mainAxisSpacing: 14.0,
                          crossAxisSpacing: 14.0,
                          children: [
                            _gridContainer(
                                "notification".tr,
                                "assets/img/dashboard/email.png",
                                NotificationAll(
                                  userData: widget.userData,
                                ),
                                val.mainData['account']['school']
                                        ['school_features']
                                    ['features_notifications']),
                            _gridContainer(
                                'examSch'.tr,
                                "assets/img/dashboard/calendar.png",
                                const ExamSchedule(),
                                val.mainData['account']['school']
                                    ['school_features']['features_exams']),
                            _gridContainer(
                                'Food Schedule'.tr,
                                "assets/img/dashboard/marks2.png",
                                const FoodSchedule(),
                                val.mainData['account']['school']
                                        ['school_features']
                                    ['features_notifications']),
                            _gridContainer(
                                'geades'.tr,
                                "assets/img/dashboard/file.png",
                                const ExamDegree(),
                                val.mainData['account']['school']
                                    ['school_features']['features_degrees']),
                            _gridContainer(
                                "com".tr,
                                "assets/img/dashboard/pen.png",
                                StudentAttend(userData: widget.userData),
                                val.mainData['account']['school']
                                    ['school_features']['features_absence']),

                            _gridContainer(
                                "Installment".tr,
                                "assets/img/dashboard/money.png",
                                const StudentSalary(),
                                val.mainData['account']['school']
                                    ['school_features']['features_accountant']),
                            _gridContainer(
                                "GPS".tr,
                                "assets/img/dashboard/bus.png",
                                StudentDriver(userData: widget.userData),
                                val.mainData['account']['school']
                                        ['school_features'][
                                    'features_drivers']), //StudentDriver(userData: widget.userData)
                            _gridContainer(
                                'lesSum'.tr,
                                "assets/img/dashboard/book.png",
                                const MonthlyMessage(),
                                true),
                            _gridContainer(
                                "chat".tr,
                                "assets/img/dashboard/group.png",
                                const ChatMain(),
                                val.mainData['account']['school']
                                    ['school_features']['features_chat']),
                          ],
                        ),
                      );
              }),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _container(String t1, String t2, img, Widget nav, width) {
    return GestureDetector(
      onTap: () {
        Get.to(() => nav);
      },
      child: Container(
        height: 90,
        width: width / 2.2,
        decoration: BoxDecoration(
          color: MyColor.purple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t1,
                        maxLines: 1,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: MyColor.white0),
                      ),
                      Text(
                        t2,
                        maxLines: 1,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: MyColor.white0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                img,
                //height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int index = 0;

  _gridContainer(t, img, Widget nav, bool features) {
    return AnimationConfiguration.staggeredGrid(
      position: index++,
      duration: const Duration(milliseconds: 375),
      columnCount: 9,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: ScaleAnimation(
          child: GestureDetector(
            onTap: () {
              if (features) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => nav),
                );
                // Get.to(() => _nav);
              } else {
                featureAttention();
              }
            },
            child: Container(
              //margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: MyColor.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 15, left: 15, top: 15),
                      child: Image.asset(
                        img,
                        height: 40,
                        color: MyColor.yellow,
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
                            color: MyColor.white0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // _liChange() {
  //   return box.listenKey('_notificationCount', (value) {
  //     return value == 0
  //         ? Icon(
  //             LineIcons.bell,
  //             color: MyColor.c0,
  //             size: 40,
  //           )
  //         : Stack(
  //             children: <Widget>[
  //               Icon(
  //                 Icons.notifications,
  //                 color: MyColor.c0,
  //                 size: 40,
  //               ),
  //               Positioned(
  //                 right: 0,
  //                 child: Container(
  //                   padding: const EdgeInsets.all(1),
  //                   decoration: BoxDecoration(
  //                     color: Colors.red,
  //                     borderRadius: BorderRadius.circular(6),
  //                   ),
  //                   constraints: const BoxConstraints(
  //                     minWidth: 12,
  //                     minHeight: 12,
  //                   ),
  //                   child: Text(
  //                     box.read('_notificationCount').toString(),
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 8,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               )
  //             ],
  //           );
  //   });
  // }
}
