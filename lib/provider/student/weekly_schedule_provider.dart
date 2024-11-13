import 'package:get/get.dart';

class WeeklyScheduleProvider extends GetxController {
  int index = 0;
  int indexTable = 0;
  List data = [];
  void addData(_data) {
    data = _data;
    update();
  }

  void remove() {
    data.clear();
    isLoading = true;
  }

  bool isLoading = true;
  void changeLoading(bool _isLoading){
    isLoading = _isLoading;
  }

  void changeIndex(int _index) {
    index = _index;
    update();
  }

  void changeIndexTable(int _index) {
    indexTable = _index;
    update();
  }
}

