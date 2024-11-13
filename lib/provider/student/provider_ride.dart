import 'package:get/get.dart';

class StudentRideProvider extends GetxController {
  List data = [];
  void addData(List _data) {
    data = _data;
    update();
  }
}
