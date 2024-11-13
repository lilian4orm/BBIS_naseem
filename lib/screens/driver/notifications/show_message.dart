import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../api_connection/driver/api_notification.dart';
import '../../../../static_files/my_appbar.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_image_grid.dart';
import '../../../../static_files/my_times.dart';

class ShowMessage extends StatefulWidget {
  final Map data;
  final String contentUrl;
  final String notificationsType;
  const ShowMessage(
      {super.key,
      required this.data,
      required this.contentUrl,
      required this.notificationsType});
  @override
  _ShowMessageState createState() => _ShowMessageState();
}

class _ShowMessageState extends State<ShowMessage> {
  void _launchURL(url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';
  @override
  void initState() {
    if (!widget.data['isRead']) {
      NotificationsAPI().updateReadNotifications(widget.data['_id']);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(widget.data['notifications_title'].toString()),
      body: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: imageGrid(
                  widget.contentUrl, widget.data['notifications_imgs'])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(toDateAndTime(widget.data['created_at'], 12)),
          ),
          if (widget.data['notifications_sender'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("${'sender'.tr} : "),
                  Text(widget.data['notifications_sender']['account_name']
                      .toString()),
                ],
              ),
            ),
          if (widget.data['notifications_link'] != "" &&
              widget.data['notifications_link'] != null)
            InkWell(
              onTap: () => _launchURL(widget.data['notifications_link']),
              child: Container(
                margin: const EdgeInsets.only(right: 20, left: 20),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: MyColor.purple.withOpacity(.17),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    widget.data['notifications_link'].toString(),
                    style: const TextStyle(fontSize: 18, color: MyColor.purple),
                  ),
                ),
              ),
            ),
          if (widget.data['notifications_pdf'] != "" &&
              widget.data['notifications_pdf'] != null)
            InkWell(
              // onTap: ()=> Get.to(()=>PdfViewer(url:MyUrl().contentApi + widget.data['notifications_pdf'])),
              child: Container(
                margin: const EdgeInsets.only(right: 20, left: 20, top: 10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: MyColor.yellow.withOpacity(.9),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'pdfShow'.tr,
                    style: const TextStyle(fontSize: 18, color: MyColor.purple),
                  ),
                ),
              ),
            ),
          if (widget.data['notifications_description'] != null)
            Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                widget.data['notifications_description'].toString(),
                style: const TextStyle(fontSize: 18, color: MyColor.purple),
              ),
            )
        ],
      ),
    );
  }
}
