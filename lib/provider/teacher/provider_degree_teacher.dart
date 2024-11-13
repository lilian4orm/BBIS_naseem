import 'package:get/get.dart';

class ExamsTeacherProvider extends GetxController {
  List data = [];
  void insertData(_data){
    data = _data;
    update();
  }
  bool isLoading = true;
  void changeLoading(bool _isLoading){
    isLoading = _isLoading;
  }
}

class DegreeTeacherProvider extends GetxController {
  List data = [];
  int index = 0;
  int indexTable = 0;
  void insertData(_data){
    data = _data;
    update();
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

class DegreeTeacherStudentListProvider extends GetxController {
  List data = [];

  void addData(List _data) {
    data = _data;
    update();
  }
}