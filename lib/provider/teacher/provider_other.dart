import 'package:get/get.dart';

class OtherProvider extends GetxController {
  List studentList = [];

  void addToList(userListx) {
    studentList = userListx;
    update();
  }
}
