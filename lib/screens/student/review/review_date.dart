import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api_connection/student/api_review.dart';
import '../../../provider/student/provider_review.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import 'show_review.dart';

class ReviewDate extends StatefulWidget {
  const ReviewDate({super.key});

  @override
  _ReviewDateState createState() => _ReviewDateState();
}

class _ReviewDateState extends State<ReviewDate> {
  @override
  void initState() {
    ReviewAPI().getReview();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('stD'.tr),
      body: GetBuilder<ReviewDateProvider>(
          builder: (val) => val.isLoading
              ? loading()
              : val.data.isEmpty
                  ? EmptyWidget(
                      image: null,
                      packageImage: PackageImage.Image_3,
                      title: 'nodta'.tr,
                      subTitle: 'noEvAdd'.tr,
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
                      itemCount: val.data.length,
                      itemBuilder: (BuildContext context, int indexes) {
                        return Container(
                          margin: const EdgeInsets.only(
                              right: 10, left: 10, top: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: MyColor.purple),
                          ),
                          child: ListTile(
                            title: Text(
                              val.data[indexes]["review_date"].toString(),
                              // toDateOnly(val.data[indexes]["review_date"]),
                              style: const TextStyle(
                                  color: MyColor.purple,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: MyColor.purple,
                            ),
                            onTap: () {
                              Get.to(() => ShowReview(
                                  data: val.data[indexes], indexItem: indexes));
                            },
                          ),
                        );
                      })),
    );
  }
}
