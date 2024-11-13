import 'package:auto_animated/auto_animated.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';
import '../../../api_connection/student/api_homework.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/student/subjects_provider.dart';
import '../../../static_files/my_loading.dart';
import '../../driver/notifications/show_message.dart';

class SubjectDetails extends StatefulWidget {
  final subject;

  const SubjectDetails({Key? key, required this.subject}) : super(key: key);

  @override
  _SubjectDetailsState createState() => _SubjectDetailsState();
}

class _SubjectDetailsState extends State<SubjectDetails> {
  final ScrollController _scrollController = ScrollController();
  var _contentUrl = '';
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  int page = 0;

  //["رسالة","تبليغ","واجب بيتي","ملخص","تقرير"]
  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
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
  void initState() {
    Map _data = {
      "study_year": _mainDataGetProvider.mainData['setting'][0]['setting_year'],
      "page": page,
      "class_school": _mainDataGetProvider.mainData['account']
          ['account_division_current']['_id'],
      "subject": widget.subject,
    };
    HomeworkAPI().getSubjectsDetails(_data).then((url) {
      setState(() {
        _contentUrl = url;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(widget.subject),
      body: GetBuilder<SubjectsProvider>(builder: (val) {
        return val.isLoading
            ? loading()
            : val.data.isEmpty
                ? EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_1,
                    title: 'لاتوجد بيانات',
                    subTitle: 'لم يتم اضافة دروس',
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
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: val.data.length,
                    itemBuilder: (BuildContext context, int indexes) {
                      return listTileList(val.data[indexes]);
                    });
      }),
    );
  }

  Container listTileList(Map data) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1.0, color: MyColor.purple),
      ),
      child: TextButton(
        onPressed: () {
          Get.to(() => ShowMessage(
              data: data,
              contentUrl: _contentUrl,
              notificationsType: data['notifications_type']));
          // Get.to(() => SubjectDetails(subject: data['subject_name']));
        },
        child: Column(
          children: [
            Row(
              children: [
                Text(data['notifications_title'] ?? ''),
                const Spacer(),
              ],
            ),
            // Row(
            //   children: [
            //     Text(
            //         DateFormat('yyyy-MM-dd h:mm a')
            //             .format(DateTime.parse(data['createdAt'])),
            //         style: const TextStyle(
            //           fontSize: 12,
            //           color: Color.fromARGB(255, 159, 158, 158),
            //         )),
            //     const Spacer(),
            //   ],
            // ),
            Row(
              children: [
                Text(data['notifications_description'] ?? ''),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
