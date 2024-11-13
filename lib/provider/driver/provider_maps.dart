import 'package:get/get.dart';

class MapDataProvider extends GetxController {
  Map newsData = {};
  bool isLocationServiceEnabled = false;
  bool permission = false;
  void addData(Map newsData) {
    newsData = newsData;
    update();
  }

  void serviceLocation(bool isLocationServiceEnabled) {
    isLocationServiceEnabled = isLocationServiceEnabled;
    update();
  }

  void permissionLocation(bool isPermissionEnabled) {
    permission = isPermissionEnabled;
    update();
  }
}
