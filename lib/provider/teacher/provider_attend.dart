import 'package:get/get.dart';

class TeacherAttendProvider extends GetxController {
  List userList = [];
  int allAbsence = 0;
  int allVacation = 0;
  int allPresence = 0;
  bool isLoading = true;
  int forThisMonth = 0;

  void addToList(_userList) {
    userList.addAll(_userList);
    update();
  }

  void changeLoading(bool _isLoading) {
    isLoading = _isLoading;
  }

  void addSingleToList(_userList) {
    if (_userList.length == 0) {
      userList = [
        {"empty": true}
      ];
    } else {
      userList = _userList;
    }
    update();
  }

  void addAttendCount(int? _allAbsence, int? _allVacation, int? _allPresence,
      int? _forThisMonth) {
    if (_allAbsence != null) {
      allAbsence = _allAbsence;
    }
    if (_allVacation != null) {
      allVacation = _allVacation;
    }
    if (_allPresence != null) {
      allPresence = _allPresence;
    }
    if (_forThisMonth != null) {
      forThisMonth = _forThisMonth;
    }
    update();
  }

  void destroyData() {
    userList.clear();
  }
}
