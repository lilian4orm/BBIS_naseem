import 'package:get/get.dart';

class LatestNewsProvider extends GetxController {
  List newsData = [];
  void addData(List newsDataR) {
    newsData = newsDataR;
    update();
  }

  String contentUrl = "";
  void changeContentUrl(String contentUrlR) {
    contentUrl = contentUrlR;
  }
}
