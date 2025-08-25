import 'package:cached_network_image/cached_network_image.dart';
import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../api_connection/student/api_general_data.dart';
import '../../provider/student/provider_genral_data.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_loading.dart';

class ConnectUs extends StatefulWidget {
  const ConnectUs({super.key});

  @override
  _ConnectUsState createState() => _ConnectUsState();
}

class _ConnectUsState extends State<ConnectUs> {
  @override
  void initState() {
    GeneralData().getContact();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: MyColor.yellow,
        title: Text(
          "callus".tr,
          style: const TextStyle(color: MyColor.purple),
        ),
        iconTheme: const IconThemeData(
          color: MyColor.purple,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GetBuilder<ContactProvider>(builder: (val) {
        return val.isLoading
            ? loading()
            : val.contact!.isEmpty
                ? EmptyWidget(
                    image: null,
                    packageImage: PackageImage.Image_1,
                    title: 'nodta'.tr,
                    subTitle: 'nodataadd'.tr,
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
                : Container(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (val.contact!['school_img'] != null)
                          Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),

                                ///image cache
                                child: CachedNetworkImage(
                                  imageUrl: val.contentUrl +
                                      val.contact!['school_img'],
                                  placeholder: (context, url) => const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )

                                //Image.network(val.contact!['school_img']),
                                ),
                          ),
                        if (val.contact!['school_img'] == null &&
                            val.contact!['school_logo'] != null)
                          Container(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),

                                ///image cache
                                child: CachedNetworkImage(
                                  imageUrl: val.contentUrl +
                                      val.contact!['school_logo'],
                                  placeholder: (context, url) => const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                )),
                          ),
                        if (val.contact!['school_website'] != null)
                          // Container(
                          //   decoration: BoxDecoration(
                          //       color: MyColor.c0.withOpacity(0.2),
                          //       borderRadius: BorderRadius.circular(10)
                          //   ),
                          //   child: TextButton(
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Text(connectUsData['website'],style: TextStyle(fontSize: 16,color: MyColor.c0),),
                          //       ],
                          //     ),
                          //     style: ButtonStyle(backgroundColor: MyColor.c0.withOpacity(0.2),),
                          //     onPressed: () async {
                          //       var _tel = "https:${connectUsData['website']}";
                          //       await canLaunch(_tel) ? await launch(_tel) : throw 'Could not launch $_tel';
                          //     },
                          //   ),
                          // ),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                MyColor.purple.withOpacity(0.2),
                              ),
                              overlayColor: WidgetStateProperty.all(
                                MyColor.purple.withOpacity(0.2),
                              ),
                            ),
                            onPressed: () async {
                              var website = val.contact!['school_website'];
                              await canLaunchUrl(website)
                                  ? await launchUrl(website)
                                  : throw 'Could not launch $website';
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  val.contact!['school_website'],
                                  style: const TextStyle(
                                      fontSize: 16, color: MyColor.purple),
                                ),
                              ],
                            ),
                          ),
                        if (val.contact!['school_description'] != null)
                          Text(
                            val.contact!['school_description'],
                            style: const TextStyle(
                                color: MyColor.purple, fontSize: 14),
                            textAlign: TextAlign.justify,
                          ),
                        Container(
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, right: 20, left: 20),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            children: [
                              if (val.contact!['school_phone'] != null)
                                Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyColor.purple),
                                      child: IconButton(
                                        icon: const Icon(
                                          LineIcons.phone,
                                          color: MyColor.yellow,
                                        ),
                                        onPressed: () async {
                                          var tel =
                                              "tel:${val.contact!['school_phone']}";
                                          await canLaunchUrl(Uri.parse(tel))
                                              ? await launchUrl(Uri.parse(tel))
                                              : throw 'Could not launch $tel';
                                        },
                                      ),
                                    ),
                                    Text(
                                      'phone'.tr,
                                      style: const TextStyle(
                                          fontSize: 14, color: MyColor.purple),
                                    )
                                  ],
                                ),
                              if (val.contact!['school_telegram'] != null)
                                Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyColor.purple),
                                      child: IconButton(
                                        icon: const Icon(
                                          LineIcons.telegram,
                                          color: MyColor.yellow,
                                        ),
                                        onPressed: () async {
                                          var tel =
                                              val.contact!['school_telegram'];
                                          await canLaunchUrl(Uri.parse(tel))
                                              ? await launchUrl(Uri.parse(tel))
                                              : throw 'Could not launch $tel';
                                        },
                                      ),
                                    ),
                                    Text(
                                      'tele'.tr,
                                      style: const TextStyle(
                                          fontSize: 14, color: MyColor.purple),
                                    )
                                  ],
                                ),
                              if (val.contact!['school_facebook'] != null)
                                Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyColor.purple),
                                      child: IconButton(
                                        icon: const Icon(
                                          LineIcons.facebookF,
                                          color: MyColor.yellow,
                                        ),
                                        onPressed: () async {
                                          var tel =
                                              val.contact!['school_facebook'];
                                          await canLaunchUrl(Uri.parse(tel))
                                              ? await launchUrl(Uri.parse(tel))
                                              : throw 'Could not launch $tel';
                                        },
                                      ),
                                    ),
                                    const Text(
                                      "facebook",
                                      style: TextStyle(
                                          fontSize: 14, color: MyColor.purple),
                                    )
                                  ],
                                ),
                              if (val.contact!['school_whatsapp'] != null)
                                Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyColor.purple),
                                      child: IconButton(
                                        icon: const Icon(
                                          LineIcons.whatSApp,
                                          color: MyColor.yellow,
                                        ),
                                        onPressed: () async {
                                          final link = WhatsAppUnilink(
                                            phoneNumber:
                                                '${val.contact!['school_whatsapp']}',
                                            text: "",
                                          );
                                          await launchUrl(
                                              Uri.parse(link.toString()));
                                        },
                                      ),
                                    ),
                                    Text(
                                      "whatsapp".tr,
                                      style: const TextStyle(
                                          fontSize: 14, color: MyColor.purple),
                                    )
                                  ],
                                ),
                              if (val.contact!['school_website'] != null)
                                Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyColor.purple),
                                      child: IconButton(
                                        icon: const Icon(
                                          LineIcons.globe,
                                          color: MyColor.yellow,
                                        ),
                                        onPressed: () async {
                                          var tel =
                                              val.contact!['school_website'];
                                          await canLaunchUrl(Uri.parse(tel))
                                              ? await launchUrl(Uri.parse(tel))
                                              : throw 'Could not launch $tel';
                                        },
                                      ),
                                    ),
                                    Text(
                                      'web'.tr,
                                      style: const TextStyle(
                                          fontSize: 14, color: MyColor.purple),
                                    )
                                  ],
                                ),
                              if (val.contact!['school_google_map'] != null)
                                Column(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: MyColor.purple),
                                      child: IconButton(
                                        icon: const Icon(
                                          LineIcons.mapMarked,
                                          color: MyColor.yellow,
                                        ),
                                        onPressed: () async {
                                          var tel =
                                              val.contact!['school_google_map'];
                                          await canLaunchUrl(Uri.parse(tel))
                                              ? await launchUrl(Uri.parse(tel))
                                              : throw 'Could not launch $tel';
                                        },
                                      ),
                                    ),
                                    Text(
                                      'loInMap'.tr,
                                      style: const TextStyle(
                                          fontSize: 14, color: MyColor.purple),
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
      }),
    );
  }
}
