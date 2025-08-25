import 'package:auto_animated/auto_animated.dart';
import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:BBInaseem/screens/student/dashboard_student/show/show_message.dart';

import '../../../api_connection/student/api_notification.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/provider_notification.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import '../../../static_files/my_times.dart';
import 'notification_all.dart';

class MonthlyMessage extends StatefulWidget {
  const MonthlyMessage({super.key});

  @override
  State<MonthlyMessage> createState() => _MonthlyMessageState();
}

class _MonthlyMessageState extends State<MonthlyMessage> {
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  // final ScrollController _scrollController = ScrollController();

  _getData() {
    // String year = _mainDataGetProvider.mainData['setting'][0]['setting_year'];
    // String classId = _mainDataGetProvider.mainData['account']
    //     ['account_division_current']['_id'];
    Map data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "page": 0,
      "class_school": _mainDataGetProvider.mainData['account']
          ['account_division_current']['_id'],
      "type": 'ملخص',
      "isRead": null
    };
    NotificationsAPI().getNotificationsMonthlyMessage(data);
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

  final formatter = NumberFormat.decimalPattern();
  DateTime now = DateTime.now();
  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('lesSum'.tr),
      body: GetBuilder<MonthlyMessageNotificationProvider>(
          builder: (val) => val.isLoading
              ? loading()
              : val.data.isEmpty
                  ? EmptyWidget(
                      image: null,
                      packageImage: PackageImage.Image_1,
                      title: 'nodta'.tr,
                      subTitle: 'noDataAd'.tr,
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
                  : Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                              color: MyColor.green,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15))),
                          margin:
                              const EdgeInsets.only(top: 20, left: 5, right: 5),
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 15, bottom: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "tot".tr,
                                style: const TextStyle(color: MyColor.white0),
                              ),
                              Text(
                                "note".tr,
                                style: const TextStyle(color: MyColor.white0),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: LiveList.options(
                              itemBuilder: animationItemBuilder(
                                (index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.to(
                                        () => ShowMessage(
                                          data: val.data[index],
                                          contentUrl: val.contentUrl,
                                          notificationsType: val.data[index]
                                              ['notifications_type'],
                                          onUpdate: () {
                                            NotificationsAPI()
                                                .updateReadMonthlyMessage(
                                                    val.data[index]['_id']);
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5, bottom: 5, top: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        color: MyColor.white0,
                                        border: Border.all(
                                            width: 1.5,
                                            color: MyColor.green,
                                            style: BorderStyle.solid),
                                      ),
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                                    left: BorderSide(
                                                        color: MyColor.green))),
                                            child: Text(
                                              val.data[index]
                                                      ["notifications_title"]
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Text(
                                            val.data[index][
                                                    "notifications_description"]
                                                .toString(),
                                            style: const TextStyle(
                                                color: MyColor.grayDark),
                                            textAlign: TextAlign.center,
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
                    )),
    );
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
              color: MyColor.green.withOpacity(.2),
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
