import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'my_color.dart';

Widget loading() {
  return Center(
      child: Padding(
    padding: const EdgeInsets.all(50.0),
    child: Lottie.asset('assets/lottie/loading.json'),
  ));
}

Widget locationEnable() {
  return Center(
      child: Padding(
    padding: const EdgeInsets.only(right: 50, left: 50),
    child: Lottie.asset('assets/lottie/location_enable.json'),
  ));
}

Widget busSchoolMoving() {
  return Center(
      child: Padding(
    padding: const EdgeInsets.only(right: 0, left: 0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/lottie/bus_school.json'),
        const SizedBox(
          height: 10,
        ),
        Text(
          'nAloo'.tr,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: MyColor.purple),
        ),
      ],
    ),
  ));
}

Widget loadingChat() {
  return Center(
      child: Padding(
    padding: const EdgeInsets.all(50.0),
    child: Lottie.asset('assets/lottie/chatLoading.json'),
  ));
}
