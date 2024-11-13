import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../api_connection/student/api_review.dart';
import '../../../provider/student/provider_review.dart';
import '../../../static_files/my_appbar.dart';
import '../../../static_files/my_color.dart';

class ShowReview extends StatefulWidget {
  final Map data;
  final int indexItem;
  const ShowReview({super.key, required this.data, required this.indexItem});

  @override
  _ShowReviewState createState() => _ShowReviewState();
}

class _ShowReviewState extends State<ShowReview> {
  TextEditingController text = TextEditingController();
  _sendData() {
    ReviewAPI().addReview(text.text, widget.data['_id']).then((res) {
      if (res['error']) {
        Get.snackbar('error'.tr, 'errF'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            icon: const Icon(
              Iconsax.close_square,
              color: Colors.white,
            ));
      } else {
        ReviewAPI().getReview();
        Get.back();
        Get.snackbar('thank'.tr, 'notAdd'.tr,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(
              Iconsax.tick_square,
              color: Colors.white,
            ));
        text.clear();
      }
    });
  }

  _noteAddedError() {
    Get.snackbar('attention'.tr, 'resAdd'.tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(
          Iconsax.edit,
          color: Colors.white,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(widget.data['review_date']),
      body: Container(
        color: Colors.grey[100],
        child: GetBuilder<ReviewDateProvider>(
            //widget.indexItem
            //_reviewDateProvider
            builder: (val) {
          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("evaluation".tr),
                      ),
                      const Divider(),
                      _row('sieLev'.tr, widget.data['review_scientific']),
                      _row('presle'.tr, widget.data['review_presence']),
                      _row('behlev'.tr, widget.data['review_behavior']),
                    ],
                  ),
                ),
              ),
              if (val.data[widget.indexItem]['review_guidance'] == null ||
                  val.data[widget.indexItem]['review_note'] != null ||
                  val.data[widget.indexItem]['review_father_note'] != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("details".tr),
                        ),
                        const Divider(),
                        if (val.data[widget.indexItem]['review_guidance'] !=
                            null)
                          _row2('guidans'.tr,
                              val.data[widget.indexItem]['review_guidance']),
                        if (val.data[widget.indexItem]['review_note'] != null)
                          _row2("notes".tr,
                              val.data[widget.indexItem]['review_note']),
                        if (val.data[widget.indexItem]['review_father_note'] !=
                            null)
                          _row2('parnot'.tr,
                              val.data[widget.indexItem]['review_father_note']),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
      floatingActionButton: GetBuilder<ReviewDateProvider>(builder: (val) {
        return FloatingActionButton(
          tooltip: 'parnot'.tr,
          onPressed: val.data[widget.indexItem]['review_father_note'] != null
              ? _noteAddedError
              : () {
                  Get.defaultDialog(
                      title: 'parnot'.tr,
                      content: Container(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 10, right: 20, left: 20),
                        child: TextFormField(
                          controller: text,
                          style: const TextStyle(
                            color: MyColor.grayDark,
                          ),
                          maxLines: 2,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              hintText: 'notes'.tr,
                              errorStyle: const TextStyle(color: MyColor.red),
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: const BorderSide(
                                  color: MyColor.grayDark,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(
                                  color: MyColor.grayDark,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: const BorderSide(
                                  color: MyColor.grayDark,
                                ),
                              ),
                              prefixIcon: const Icon(Iconsax.note),
                              filled: true
                              //fillColor: Colors.green
                              ),
                        ),
                      ),
                      confirm: MaterialButton(
                        onPressed: () {
                          text.text.length <= 5
                              ? Get.snackbar("error".tr, 'filCor'.tr,
                                  backgroundColor: Colors.orangeAccent)
                              : _sendData();
                        },
                        color: Colors.green,
                        child: Text(
                          "send".tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ));
                },
          backgroundColor: MyColor.purple.withOpacity(0.9),
          child: const Icon(Iconsax.note_add),
        );
      }),
    );
  }

  Widget _row(String title, String desc) {
    return ListTile(
      leading: Text(
        title,
        style: const TextStyle(
            fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      title: Text(
        desc,
        style: const TextStyle(
            fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      trailing: _icon(desc),
    );
  }

  Widget _row2(String title, String desc) {
    return ListTile(
      leading: Text(
        title,
        style: const TextStyle(
            fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        desc,
        style: const TextStyle(fontSize: 12, color: Colors.black),
        textAlign: TextAlign.justify,
      ),
    );
  }

  _icon(desc) {
    if (desc == "ممتاز") {
      return const Icon(
        Iconsax.clipboard_tick5,
        color: Colors.green,
      );
    } else if (desc == "جيد جدا") {
      return const Icon(
        Iconsax.clipboard_tick5,
        color: Colors.orange,
      );
    } else if (desc == "جيد") {
      return const Icon(
        Iconsax.clipboard_tick5,
        color: Colors.purple,
      );
    } else if (desc == "مقبول") {
      return const Icon(
        Iconsax.clipboard_tick5,
        color: Colors.blue,
      );
    } else if (desc == "ضعيف") {
      return const Icon(
        Iconsax.clipboard_close5,
        color: Colors.red,
      );
    }
  }
}
