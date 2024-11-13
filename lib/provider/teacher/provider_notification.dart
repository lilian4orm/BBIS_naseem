import 'package:get/get.dart';

class TeacherNotificationProvider extends GetxController {
  List data = [];
  int countRead = 0;
  bool? isRead;
  int countUnread = 0;
  int countAll = 0;
  bool isLoading = true;
  String contentUrl = "";
  void insertData(_data) {
    data.addAll(_data);
    update();
  }

  void changeRead(_isRead) {
    isRead = _isRead;
    //update();
  }

  void editReadMap(String _id) {
    int _indexItem = data.indexWhere((element) => element['_id'] == _id);
    if(!data[_indexItem]['isRead']){
      countRead++;
      countUnread--;
      data[_indexItem]['isRead'] = true;
      update();
    }
  }
  void deleteNotification(String _id) {
    data.removeWhere((element) => element['_id'] == _id);
    update();
  }

  void changeCount(int _countAll, int _countRead, int _countUnread) {
    countAll = _countAll;
    countRead = _countRead;
    countUnread = _countUnread;
    update();
  }

  void remove() {
    data.clear();
    isLoading = true;
  }

  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }

  void changeContentUrl(String _contentUrl) {
    contentUrl = _contentUrl;
  }
}

class TeacherHomeworkAnswersProvider extends GetxController {
  List data = [];

  bool isLoading = true;
  String contentUrl = "";
  void insertData(_data) {
    data.addAll(_data);
    update();
  }

  void deleteNotification(String _id) {
    data.removeWhere((element) => element['_id'] == _id);
    update();
  }

  void remove() {
    data.clear();
    isLoading = true;
  }

  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }

  void changeContentUrl(String _contentUrl) {
    contentUrl = _contentUrl;
  }
}

class SelectSwitchProvider extends GetxController {
  int? radioValue = -1;

  void change(int? value) {
    radioValue = value;
    update();
  }
}
