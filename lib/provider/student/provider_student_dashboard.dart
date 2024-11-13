import 'package:flutter/material.dart';
import 'package:get/get.dart';


class StudentDashboardProvider extends GetxController {
  //TokenProvider
  int selectedIndex = 0;
  List<Widget>? widgetOptions;
  void initWidget(List<Widget> _data){
    widgetOptions = _data;
    update();
  }
  void changeIndex(int index){
    selectedIndex=index;
    update();
  }
  // void addData(List _data) {
  //   data = _data;
  //   update();
  // }
}
