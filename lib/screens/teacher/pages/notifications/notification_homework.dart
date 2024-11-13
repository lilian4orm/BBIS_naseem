import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:line_icons/line_icons.dart';
import '../../../../api_connection/teacher/api_notification.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/teacher/provider_notification.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_loading.dart';
import '../../../../static_files/my_times.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'notification_add.dart';
import 'show/show_message.dart';
import '../teacher_attend.dart';
import 'package:auto_animated/auto_animated.dart';


class NotificationHomework extends StatefulWidget {
  final Map userData;
  const NotificationHomework({Key? key, required this.userData}) : super(key: key);

  @override
  _NotificationHomeworkState createState() => _NotificationHomeworkState();
}

class _NotificationHomeworkState extends State<NotificationHomework> {
  final ScrollController _scrollController = ScrollController();
  final MainDataGetProvider _mainDataGetProvider = Get.put(MainDataGetProvider());
  final TeacherNotificationProvider _notificationProvider = Get.put(TeacherNotificationProvider());
  List accountDivisionList = [];

  int page = 0;
  String? type;
  initFunction() {
    Map _data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "page": page,
      "class_school": accountDivisionList,
      "type": "واجب بيتي",
      "isRead": _notificationProvider.isRead
    };
    NotificationsAPI().getNotifications(_data);
  }

  final options = const LiveOptions(
    // Show each item through (default 250)
    showItemInterval: Duration(milliseconds: 150),

    // Animation duration (default 250)
    showItemDuration: Duration(milliseconds: 200),

    // Animations starts at 0.05 visible
    // item fraction in sight (default 0.025)
    visibleFraction: 0.05,

    // Repeat the animation of the appearance
    // when scrolling in the opposite direction (default false)
    // To get the effect as in a showcase for ListView, set true
    reAnimateOnVisibility: true,
  );
  @override
  void dispose() {
    _notificationProvider.remove();
    _scrollController.dispose();
    accountDivisionList.clear();
    super.dispose();
  }

  @override
  void initState() {
    for(Map accountDivision in _mainDataGetProvider.mainData['account']['account_division']){
      accountDivisionList.add(accountDivision['_id']);
    }
    initFunction();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        EasyLoading.show(status: "جار جلب البيانات");
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
        title: const Text(
          "الواجب البيتي",
          style: TextStyle(color: MyColor.purple),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: MyColor.purple,
        ),
        elevation: 0,
        actions: [
          GetBuilder<TeacherNotificationProvider>(builder: (val) {
            return IconButton(
              onPressed: () {
                if (val.isRead == null) {
                  val.changeRead(true);
                } else if (val.isRead == true) {
                  val.changeRead(false);
                } else {
                  val.changeRead(null);
                }
                page = 0;
                val.remove();
                EasyLoading.show(status: "جار جلب البيانات");
                initFunction();
              },
              icon: val.isRead == null
                  ? const Icon(CommunityMaterialIcons.eye_off_outline)
                  : val.isRead == true
                  ? const Icon(CommunityMaterialIcons.eye_check_outline)
                  : const Icon(CommunityMaterialIcons.eye_remove_outline),
            );
          })
        ],
      ),
      body: GetBuilder<TeacherNotificationProvider>(
          builder: (val) => val.isLoading
              ? loading()
              : val.data.isEmpty
              ? EmptyWidget(
            image: null,
            packageImage: PackageImage.Image_1,
            title: 'لاتوجد اشعارات',
            subTitle: 'لم يتم اضافة اشعار خاص بك',
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
                          color: val.data[indexes]["isRead"] ? MyColor.purple : MyColor.red,
                          indicator: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: val.data[indexes]["isRead"] ? MyColor.purple : MyColor.red,
                              ),
                              child: Icon(
                                _icon(val.data[indexes]["notifications_type"]),
                                size: 15,
                                color: MyColor.white0,
                              )),
                        ),
                        afterLineStyle: LineStyle(
                          color: MyColor.grayDark.withOpacity(.2),
                        ),
                        beforeLineStyle: LineStyle(
                          color: MyColor.grayDark.withOpacity(.2),
                        ),
                        startChild: _dateTimeLine(val.data[indexes]["created_at"]),
                        endChild: Container(
                          margin: const EdgeInsets.only(right: 10, left: 10, top: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: val.data[indexes]["isRead"] ? MyColor.purple : MyColor.red),
                          ),
                          child: ListTile(
                            title: Text(
                              val.data[indexes]["notifications_title"].toString(),
                              style: const TextStyle(color: MyColor.purple, fontWeight: FontWeight.bold),
                            ),
                            subtitle: val.data[indexes]["notifications_description"] != null
                                ? Text(val.data[indexes]["notifications_description"].toString())
                                : null,
                            trailing: _star(val.data[indexes]['notifications_sender']['_id'] ==_mainDataGetProvider.mainData['account']['_id']),
                            //val.data[indexes]['notifications_sender']['_id'] !=_mainDataGetProvider.mainData['account']['_id']
                            onTap: () {
                              _navPage(val.data[indexes], val.contentUrl);
                            },
                            onLongPress: val.data[indexes]['notifications_sender']['_id'] !=_mainDataGetProvider.mainData['account']['_id'] ?null: (){
                              Get.defaultDialog(
                                title: "حذف اشعار",
                                titleStyle: const TextStyle(color: MyColor.red),
                                content: Text("هل انت متأكد من عملية حذف ال${val.data[indexes]['notifications_type']}؟"),
                                textConfirm: "حذف",
                                confirmTextColor: MyColor.white0,
                                onConfirm: (){
                                  Map _data = {
                                    "notifications_id":val.data[indexes]['_id'],
                                    "notifications_imgs":val.data[indexes]['notifications_imgs'],
                                    "notifications_pdf":val.data[indexes]['notifications_pdf'],
                                  };
                                  NotificationsAPI().deleteNotification(_data).then((res){
                                    Get.back();
                                  });
                                },
                                textCancel: "الغاء",
                                cancelTextColor: MyColor.purple,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const NotificationAdd());
        },
        tooltip: "اضافة اشعار",
        backgroundColor: MyColor.purple,
        child: const Icon(
          LineIcons.bell,
          color: MyColor.yellow,
        ),
      ),
    );
  }

  _navPage(Map _data, String _contentUrl) {
    List _pageNotifications = ["رسالة", "تبليغ", "واجب بيتي", "ملخص", "تقرير"];

    if (_pageNotifications.contains(_data['notifications_type'])) {
      Get.to(() => ShowMessage(data: _data, contentUrl: _contentUrl, notificationsType: _data['notifications_type']));
    } else if (_data['notifications_type'] == "الحضور") {
      Get.to(() => TeacherAttend(
        userData: widget.userData,
      ));
    } else if (_data['notifications_type'] == "اقساط") {
      // Get.to(() => Installments())
    } else if (_data['notifications_type'] == "الميلاد") {
      // Get.to(() => Installments())
    }

    // else if (_data['notifications_type'] == "البصمة") {
    //   // Get.to(() => Installments())
    // }
  }

  _star(bool _isMine) {
    if(_isMine){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Icon(LineIcons.starAlt,size: 20,color: MyColor.yellow,),
        ],
      );
    }
  }

  IconData _icon(_type) {
    if (_type == "رسالة") {
      return Iconsax.message;
    } else if (_type == "واجب بيتي") {
      return Iconsax.book;
    } else if (_type == "تقرير") {
      return Iconsax.presention_chart;
    } else if (_type == "اقساط") {
      return Iconsax.money_send;
    } else if (_type == "الحضور") {
      return Iconsax.frame;
    } else if (_type == "تبليغ") {
      return Iconsax.edit;
    } else if (_type == "ملخص") {
      return Iconsax.task;
    } else if (_type == "البصمة") {
      return Iconsax.finger_scan;
    } else if (_type == "الميلاد") {
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
