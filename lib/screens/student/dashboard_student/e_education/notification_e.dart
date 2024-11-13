import 'package:auto_animated/auto_animated.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../api_connection/student/api_notification.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/student/provider_notification.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_loading.dart';
import '../../../../static_files/my_times.dart';
import '../show/show_message.dart';

class NotificationE extends StatefulWidget {
  const NotificationE({Key? key, required this.userData}) : super(key: key);
  final Map userData;

  @override
  _NotificationEState createState() => _NotificationEState();
}

class _NotificationEState extends State<NotificationE> {
  final ScrollController _scrollController = ScrollController();
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  final NotificationProvider _notificationProvider =
      Get.put(NotificationProvider());
  int page = 0;
  initFunction() {
    Map data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "page": page,
      "class_school": _mainDataGetProvider.mainData['account']
          ['account_division_current']['_id'],
      "type": "التعليم الالكتروني",
      "isRead": _notificationProvider.isRead
    };
    NotificationsAPI().getNotificationsE(data);
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
          "التعليم الالكتروني",
          style: TextStyle(color: MyColor.purple),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: MyColor.purple,
        ),
        elevation: 0,
        actions: [
          GetBuilder<NotificationProvider>(builder: (val) {
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
      body: GetBuilder<NotificationProviderE>(
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
                              color: val.data[indexes]["isRead"]
                                  ? MyColor.purple
                                  : MyColor.red,
                              indicator: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: val.data[indexes]["isRead"]
                                        ? MyColor.purple
                                        : MyColor.red,
                                  ),
                                  child: const Icon(
                                    Iconsax.message,
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
                            startChild:
                                _dateTimeLine(val.data[indexes]["created_at"]),
                            endChild: Container(
                              margin: const EdgeInsets.only(
                                  right: 10, left: 10, top: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: val.data[indexes]["isRead"]
                                        ? MyColor.purple
                                        : MyColor.red),
                              ),
                              child: ListTile(
                                title: Text(
                                  val.data[indexes]["notifications_title"]
                                      .toString(),
                                  style: const TextStyle(
                                      color: MyColor.purple,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: val.data[indexes]
                                            ["notifications_description"] !=
                                        null
                                    ? Text(val.data[indexes]
                                            ["notifications_description"]
                                        .toString())
                                    : null,
                                onTap: () {
                                  _navPage(val.data[indexes], val.contentUrl);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )),
    );
  }

  _navPage(Map data, String contentUrl) {
    Get.to(() => ShowMessage(
        data: data,
        contentUrl: contentUrl,
        notificationsType: data['notifications_type']));
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
}) {
  return (
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
}
