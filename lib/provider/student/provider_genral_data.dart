import 'package:get/get.dart';

class AdsProvider extends GetxController {
  List? ads;
  String contentUrl = "";
  bool isLoading = true;
  void addData(List _list) {
    ads = _list;
    update();
  }

  void changeContentUrl(String _contentUrl) {
    contentUrl = _contentUrl;
  }

  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }
}

class SchoolsProvider extends GetxController {
  List? schools;
  bool isLoading = true;
  void addData(List _list) {
    schools = _list;
    update();
  }

  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }
}

class GovernorateProvider extends GetxController {
  List? governorate;
  bool isLoading = true;
  void addData(List _list) {
    governorate = _list;
    update();
  }

  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }
}

class ContactProvider extends GetxController {
  Map? contact;
  bool isLoading = true;
  String contentUrl = "";
  void addData(Map _map) {
    contact = _map;
    update();
  }

  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }

  void changeContentUrl(String _contentUrl) {
    contentUrl = _contentUrl;
  }
}

/// old data [-----start----]
class SubjectProvider extends GetxController {
  Map? subject;
  String contentUrl = "";
  void addToSubject(Map _map) {
    subject = _map;
    update();
  }

  void changeContentUrl(String _contentUrl) {
    contentUrl = _contentUrl;
  }

  void insertData(body) {}
}

class TeachersProvider extends GetxController {
  List? teachers;
  String contentUrl = "";
  void addToTeachers(List _list) {
    teachers = _list;
    update();
  }

  void changeContentUrl(String _contentUrl) {
    contentUrl = _contentUrl;
  }
}


/// old data [-----end----]
