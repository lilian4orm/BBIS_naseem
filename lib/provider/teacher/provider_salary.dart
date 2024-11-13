import 'package:get/get.dart';

class TeacherSalaryProvider extends GetxController {
  Map data = {};
  bool isLoading = true;
  void changeLoading(bool _isLoading){
    isLoading = _isLoading;
  }
  void addData(Map _data) {
    data = _data;
    update();
  }
}

class TeacherFullSalaryProvider extends GetxController {
  List  data = [];
  bool isLoading = true;
  void changeLoading(bool _isLoading){
    isLoading = _isLoading;
  }
  void addData(List _data) {
    data = _data;
    update();
  }
}