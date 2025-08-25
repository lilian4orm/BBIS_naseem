import 'package:auto_animated/auto_animated.dart';
import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../api_connection/student/api_notification.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/provider_notification.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import '../../../static_files/my_times.dart';
import '../review/review_date.dart';
import 'daily_exams.dart';
import 'show/show_message.dart';
import 'student_attend.dart';
import 'student_salary/student_salary.dart';

class NotificationAll extends StatefulWidget {
  final Map userData;

  const NotificationAll({super.key, required this.userData});

  @override
  _NotificationAllState createState() => _NotificationAllState();
}

class _NotificationAllState extends State<NotificationAll> {
  final ScrollController _scrollController = ScrollController();
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  final NotificationProvider _notificationProvider =
      Get.put(NotificationProvider());
  int page = 0;
  String? typeSelected;
  Map<String, String> arabicTranslations = {
    'letter': 'رسالة',
    'summary': 'ملخص',
    'all': 'الكل',
  };
  List typeList = [
    "letter".tr,
    'hoWork'.tr,
    'tot'.tr,
    'dexam'.tr,
    "report".tr,
    "Installment".tr,
    // 'eTeach'.tr,
    'birthday'.tr
  ];

  initFunction() {
    Map data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "page": page,
      "class_school": _mainDataGetProvider.mainData['account']
          ['account_division_current']['_id'],
      "type": getWordNoti(typeSelected),
      "isRead": _notificationProvider.isRead
    };
    NotificationsAPI().getNotifications(data);
  }

  final options = const LiveOptions(
    // Show each item through (default 250)
    showItemInterval: Duration(milliseconds: 100),

    // Animation duration (default 250)
    showItemDuration: Duration(milliseconds: 200),

    // Animations starts at 0.05 visible
    // item fraction in sight (default 0.025)
    visibleFraction: 0.025,

    // Repeat the animation of the appearance
    // when scrolling in the opposite direction (default false)
    // To get the effect as in a showcase for ListView, set true
    reAnimateOnVisibility: true,
  );

  @override
  void dispose() {
    _notificationProvider.remove();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initFunction();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        EasyLoading.show(status: 'getData'.tr);
        page++;
        initFunction();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        title: Text(
          "notification".tr,
          style: const TextStyle(color: MyColor.purple),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: MyColor.purple,
        ),
        elevation: 0,
        actions: const [
          // GetBuilder<NotificationProvider>(builder: (val) {
          //   return IconButton(
          //     onPressed: () {
          //       if (val.isRead == null) {
          //         val.changeRead(true);
          //       } else if (val.isRead == true) {
          //         val.changeRead(false);
          //       } else {
          //         val.changeRead(null);
          //       }
          //       page = 0;
          //       val.remove();
          //       EasyLoading.show(status: "جار جلب البيانات");
          //       initFunction();
          //     },
          //     icon: val.isRead == null
          //         ? const Icon(CommunityMaterialIcons.eye_off_outline)
          //         : val.isRead == true
          //             ? const Icon(CommunityMaterialIcons.eye_check_outline)
          //             : const Icon(CommunityMaterialIcons.eye_remove_outline),
          //   );
          // })
        ],
      ),
      body: GetBuilder<NotificationProvider>(
          builder: (val) => Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _button(null),
                        for (int i = 0; i < typeList.length; i++)
                          _button(typeList[i])
                      ],
                    ),
                  ),
                  Expanded(
                    child: val.isLoading
                        ? loading()
                        : val.data.isEmpty
                            ? EmptyWidget(
                                image: null,
                                packageImage: PackageImage.Image_1,
                                title: 'noNoti'.tr,
                                subTitle: 'noNotiAdd'.tr,
                                titleTextStyle: const TextStyle(
                                  fontSize: 22,
                                  color: Color(0xff9da9c7),
                                  fontWeight: FontWeight.w500,
                                ),
                                subtitleTextStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xffabb8d6),
                                ),
                              )
                            : isSummery == "ملخص"
                                ? Column(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                            color: MyColor.purple,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15))),
                                        margin: const EdgeInsets.only(
                                            top: 20, left: 5, right: 5),
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 15,
                                            bottom: 15),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Link",
                                              style: TextStyle(
                                                  color: MyColor.white0),
                                            ),
                                            Text(
                                              "Notes",
                                              style: TextStyle(
                                                  color: MyColor.white0),
                                            ),
                                            Text(
                                              "Subject",
                                              style: TextStyle(
                                                  color: MyColor.white0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: LiveList.options(
                                            itemBuilder: animationItemBuilder(
                                              (ind) {
                                                return InkWell(
                                                  onTap: () {
                                                    _navPage(val.data[ind],
                                                        val.contentUrl);
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5,
                                                            top: 5),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 15),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  20)),
                                                      color: MyColor.white0,
                                                      border: Border.all(
                                                          width: 1.5,
                                                          color: MyColor.green,
                                                          style: BorderStyle
                                                              .solid),
                                                    ),
                                                    width: 100,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5),
                                                          decoration: const BoxDecoration(
                                                              border: Border(
                                                                  left: BorderSide(
                                                                      color: MyColor
                                                                          .green))),
                                                          child: Text(
                                                            val.data[ind][
                                                                    "notifications_title"]
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            val.data[ind][
                                                                    "notifications_description"]
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color: MyColor
                                                                    .grayDark),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        const Icon(
                                                          Icons.link_rounded,
                                                          color: Colors.grey,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            itemCount: val.data.length,
                                            options: options),
                                      ),
                                    ],
                                  )
                                //نهاية الملخص
                                //end summery

                                : LiveList.options(
                                    options: options,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    controller: _scrollController,
                                    itemCount: val.data.length,
                                    itemBuilder: animationItemBuilder(
                                      (indexes) {
                                        return TimelineTile(
                                          alignment: TimelineAlign.manual,
                                          lineXY: .2,
                                          isFirst: indexes == 0,
                                          indicatorStyle: IndicatorStyle(
                                            color: val.data[indexes]["isRead"]
                                                ? MyColor.purple
                                                : MyColor.red,
                                            indicator: Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: val.data[indexes]
                                                          ["isRead"]
                                                      ? MyColor.purple
                                                      : MyColor.red,
                                                ),
                                                child: Icon(
                                                  _icon(val.data[indexes]
                                                      ["notifications_type"]),
                                                  size: 15,
                                                  color: MyColor.white0,
                                                )),
                                          ),
                                          afterLineStyle: LineStyle(
                                            color: MyColor.grayDark
                                                .withOpacity(.2),
                                          ),
                                          beforeLineStyle: LineStyle(
                                            color: MyColor.grayDark
                                                .withOpacity(.2),
                                          ),
                                          startChild: _dateTimeLine(
                                              val.data[indexes]["created_at"]),
                                          endChild: Container(
                                            margin: const EdgeInsets.only(
                                                right: 10, left: 10, top: 10),
                                            padding: const EdgeInsets.only(
                                                bottom: 10, top: 2),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: val.data[indexes]
                                                          ["isRead"]
                                                      ? MyColor.purple
                                                      : MyColor.red),
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                val.data[indexes]
                                                        ["notifications_title"]
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: MyColor.purple,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle: val.data[indexes][
                                                          "notifications_description"] !=
                                                      null
                                                  ? Text(
                                                      val.data[indexes][
                                                              "notifications_description"]
                                                          .toString(),
                                                      maxLines: 5,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : null,
                                              trailing: _notificationsType(
                                                  val.data[indexes]
                                                      ['notifications_type']),
                                              onTap: () {
                                                _navPage(val.data[indexes],
                                                    val.contentUrl);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                  ),
                ],
              )),
    );
  }

  _navPage(Map data, String contentUrl) {
    List pageNotifications = [
      "رسالة",
      'تبليغ',
      'ملخص',
      "امتحان يومي",
      "اخر الاخبار",
      "واجب بيتي",
      'امتحان',
      "تقرير",
      'التعليم الالكتروني',
      'اشعار',
      "دروس",
      "الميلاد"
    ];
    if (data['notifications_title'] == "تم اضافة تقييم جديد") {
      setState(() {
        NotificationsAPI().updateReadNotifications(data['_id']);
      });
      Get.to(() => const ReviewDate());
    } else if (data['notifications_title'] == "تم اضافة حضور / غياب / اجازة") {
      setState(() {
        NotificationsAPI().updateReadNotifications(data['_id']);
      });
      Get.to(() => StudentAttend(userData: widget.userData));
    } else if (data['notifications_type'] == "امتحان يومي") {
      Get.to(() => const DailyExams());
      setState(() {
        Get.put(NotificationsAPI()).updateReadNotifications(data["_id"]);
      });
    } else if (data['notifications_type'] == "الحضور") {
      setState(() {
        Get.put(NotificationsAPI()).updateReadNotifications(data["_id"]);
      });
      Get.to(() => StudentAttend(
            userData: widget.userData,
          ));
    } else if (data['notifications_type'] == "اقساط") {
      setState(() {
        Get.put(NotificationsAPI()).updateReadNotifications(data["_id"]);
      });
      Get.to(() => const StudentSalary());
    } else if (data['notifications_type'] == "الميلاد") {
      // Get.to(() => Installments())
    } else if (pageNotifications.contains(data['notifications_type'])) {
      Logger().i('yest');

      Get.to(() => ShowMessage(
            data: data,
            contentUrl: contentUrl,
            notificationsType: data['notifications_type'],
            onUpdate: () {
              Logger().i(data);
            },
          ));
      setState(() {
        NotificationsAPI().updateReadNotifications(data['_id']);
      });
    } else {
      setState(() {
        NotificationsAPI().updateReadNotifications(data['_id']);
      });
    }
  }

  String isSummery = "";
  String? getWordNoti(name) {
    if (name == "Message") {
      return "رسالة";
    } else if (name == "Home Work") {
      return "واجب بيتي";
    } else if (name == "Daily Exam") {
      return "امتحان يومي";
    } else if (name == "E-Learning") {
      return "التعليم الالكتروني";
    } else if (name == "Report") {
      return "تقرير";
    } else if (name == "Summary") {
      return "ملخص";
    } else if (name == "fin") {
      return "البصمة";
    } else if (name == "Fingerprint") {
      return "الميلاد";
    } else if (name == "Instalment") {
      return "الاقساط";
    } else if (name == 'All') {
      return null;
    } else {
      return name;
    }
    //           "Installment": "الاقساط",

    // 'letter': 'رسالة',
    //       'hoWork': 'الواجب البيتي',
    //       'dexam': "امتحان يومي",
    //       'eTeach': "التعليم الالكتروني",
    //       'report': 'تقرير',
    //       'tot': "ملخص",
    //       'fin': "البصمة",
    //       'birthday': 'الميلاد',
    // "Installment": "Instalment",
//
    //  "letter": "Message",
    //       "hoWork": "Home Work",
    //       "dexam": "Daily Exam",
    //       "eTeach": "E-Learning",
    //       "report": "Report",
    //       "tot": "Summary",
    //       "fin": "Fingerprint",
    //       "birthday": "Birthday",
  }

  _button(String? type) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: () {
          page = 0;
          typeSelected = type;
          print(typeSelected);
          Get.put(NotificationProvider()).remove();
          EasyLoading.show(status: 'getData'.tr);
          initFunction();

          if (type == "ملخص") {
            isSummery = "ملخص";
          } else {
            isSummery = "";
          }
        },
        color: typeSelected == type ? MyColor.yellow : MyColor.purple,
        textColor: typeSelected == type ? MyColor.purple : MyColor.white0,
        child: Text(type ?? "all".tr),
      ),
    );
  }

  _notificationsType(type) {
    if (type == "homework") {
      return Text('hoWork'.tr);
    } else if (type == "message") {
      return Text('letter'.tr);
    } else if (type == "report") {
      return Text('report'.tr);
    } else if (type == "installments") {
      return Text('Installments'.tr);
    } else if (type == "vacations") {
      return Text('vocation'.tr);
    } else if (type == "announcement") {
      return Text('tabl'.tr);
    }
  }

  IconData _icon(type) {
    if (type == "رسالة") {
      return Iconsax.message;
    } else if (type == "واجب بيتي") {
      return Iconsax.book;
    } else if (type == "تقرير") {
      return Iconsax.presention_chart;
    } else if (type == "اقساط") {
      return Iconsax.money_send;
    } else if (type == "الحضور") {
      return Iconsax.frame;
    } else if (type == "تبليغ") {
      return Iconsax.edit;
    } else if (type == "ملخص") {
      return Iconsax.task;
    } else if (type == "البصمة") {
      return Iconsax.finger_scan;
    } else if (type == "الميلاد") {
      return Iconsax.cake;
    } else {
      return Iconsax.timer;
    }
  }

  Widget _dateTimeLine(int createdAt) {
    String currentYear = DateTime.now().year.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          toDayOnly(createdAt),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Container(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
            decoration: BoxDecoration(
              color: MyColor.purple.withOpacity(.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              toMonthOnlyAR(createdAt),
              style: const TextStyle(fontSize: 11),
            )),
        if (currentYear != toYearOnly(createdAt))
          Text(
            toYearOnly(createdAt),
            style: const TextStyle(fontSize: 11),
          ),
      ],
    );
  }
}

Widget Function(
  BuildContext context,
  int index,
  Animation<double> animation,
) animationItemBuilder(
  Widget Function(int index) child, {
  EdgeInsets padding = EdgeInsets.zero,
}) =>
    (
      BuildContext context,
      int index,
      Animation<double> animation,
    ) =>
        FadeTransition(
          opacity: Tween<double>(
            begin: 0,
            end: 1,
          ).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(animation),
            child: Padding(
              padding: padding,
              child: child(index),
            ),
          ),
        );
