import 'package:get/get.dart';

class NotificationDriverProvider extends GetxController {
  List data = [];
  bool? isRead;
  bool isLoading = true;
  String contentUrl = "";
  void insertData(data) {
    data.addAll(data);
    update();
  }

  void changeRead(isRead) {
    isRead = isRead;
    //update();
  }

  void editReadMap(String id) {
    int indexItem = data.indexWhere((element) => element['_id'] == id);
    if (!data[indexItem]['isRead']) {
      data[indexItem]['isRead'] = true;
      update();
    }
  }

  void remove() {
    data.clear();
    isLoading = true;
  }

  void changeLoading(bool isLoading) {
    isLoading = isLoading;
  }

  void changeContentUrl(String contentUrl) {
    contentUrl = contentUrl;
  }
}
