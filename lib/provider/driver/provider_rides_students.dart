import 'package:get/get.dart';

class RidesStudentsProvider extends GetxController {
  List data = [];
  void insertData(data) {
    data = data;
    update();
  }

  bool isLoading = true;
  void changeLoading(bool isLoading) {
    isLoading = isLoading;
  }
}
