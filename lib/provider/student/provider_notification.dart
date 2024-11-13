import 'package:get/get.dart';

class NotificationProvider extends GetxController {
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

class NotificationProviderE extends GetxController {
  List data = [];
  int countRead = 0;
  bool? isRead;
  int countUnread = 0;
  int countAll = 0;
  bool isLoading = true;
  String contentUrl = "";
  void insertData(_data) {
    data.clear();
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

class NotificationProviderHomeWork extends GetxController {
  List data = [];
  int countRead = 0;
  bool? isRead;
  int countUnread = 0;
  int countAll = 0;
  bool isLoading = true;
  String contentUrl = "";
  void insertData(_data) {
    data.clear();
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
class NotificationProviderMassages extends GetxController {
  List data = [];
  int countRead = 0;
  bool? isRead;
  int countUnread = 0;
  int countAll = 0;
  bool isLoading = true;
  String contentUrl = "";
  void insertData(_data) {
    data.clear();
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


class MonthlyMessageNotificationProvider extends GetxController {
  List data = [];
  int countRead = 0;
  bool? isRead;
  int countUnread = 0;
  int countAll = 0;
  bool isLoading = true;
  String contentUrl = "";
  void insertData(_data) {
    data.clear();
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
