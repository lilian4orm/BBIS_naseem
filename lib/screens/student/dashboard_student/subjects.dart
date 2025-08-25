import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api_connection/student/api_homework.dart';
import '../../../provider/student/subjects_provider.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import 'subject_details.dart';

class SubjectsList extends StatefulWidget {
  const SubjectsList({Key? key}) : super(key: key);

  @override
  _SubjectsListState createState() => _SubjectsListState();
}

class _SubjectsListState extends State<SubjectsList> {
  final ScrollController _scrollController = ScrollController();
  // final MainDataGetProvider _mainDataGetProvider =
  //     Get.put(MainDataGetProvider());
  bool _isLoading = true;
  _getData() {
    HomeworkAPI().getSubjectsList().then((result) {
      print(result);
      if (result) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _isLoading = true;
      });
    });
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   Scaffold(appBar: myAppBar("ملخص الدروس"), body: Container());
    // }
    return Scaffold(
      appBar: myAppBar("ملخص الدروس"),
      body: GetBuilder<SubjectsProvider>(builder: (val) {
        return _isLoading
            ? loading()
            : val.isLoading
                ? loading()
                : val.data.isEmpty
                    ? EmptyWidget(
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
          Get.to(() => SubjectDetails(subject: data['subject_name']));
        },
        child: Column(
          children: [
            Row(
              children: [
                const Text("المادة: "),
                Text(data['subject_name'] ?? ''),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
