import 'package:get/get.dart';

class SubjectsProvider extends GetxController {
  List data = [];
  void insertData(_data) {
    data = _data;
    update();
  }

  bool isLoading = true;
  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }
}
