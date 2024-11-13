import 'package:BBInaseem/main.dart';
import 'package:BBInaseem/screens/auth/login_page.dart';
import 'package:BBInaseem/static_files/my_color.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class GuestWidget extends StatelessWidget {
  const GuestWidget({super.key});
  static int index = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/img/logo.png',
              width: size.width,
              height: size.height * .3,
            ),
            AnimationLimiter(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                physics: const BouncingScrollPhysics(),
                childAspectRatio: 1.2,
                padding: const EdgeInsets.only(top: 15, left: 6, right: 6),
                mainAxisSpacing: 14.0,
                crossAxisSpacing: 14.0,
                children: [
                  _gridContainer(
                    "notification".tr,
                    "assets/img/dashboard/email.png",
                  ),
                  _gridContainer(
                      'examSch'.tr, "assets/img/dashboard/calendar.png"),
                  _gridContainer('tabs'.tr, "assets/img/dashboard/marks2.png"),
                  _gridContainer('geades'.tr, "assets/img/dashboard/file.png"),
                  _gridContainer("com".tr, "assets/img/dashboard/pen.png"),
                  _gridContainer(
                      "Installment".tr, "assets/img/dashboard/money.png"),
                  _gridContainer("GPS".tr, "assets/img/dashboard/bus.png"),
                  _gridContainer('lesSum'.tr, "assets/img/dashboard/book.png"),
                  _gridContainer("chat".tr, "assets/img/dashboard/group.png"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'wellcome'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  sharePref.clear();
                  Get.offAll(() => const LoginPage());
                },
                child: Text(
                  'Login button'.tr,
                  style: const TextStyle(
                    color: MyColor.white0,
                    fontSize: 20,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  _gridContainer(t, img) {
    return AnimationConfiguration.staggeredGrid(
      position: index++,
      duration: const Duration(milliseconds: 375),
      columnCount: 9,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: ScaleAnimation(
          child: GestureDetector(
            child: Container(
              //margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: MyColor.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 15, left: 15, top: 15),
                      child: Image.asset(
                        img,
                        height: 40,
                        color: MyColor.yellow,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: AutoSizeText(
                        t,
                        maxLines: 1,
                        minFontSize: 12,
                        maxFontSize: 25,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: MyColor.white0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
