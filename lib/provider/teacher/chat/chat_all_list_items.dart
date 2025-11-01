import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../api_connection/teacher/chat/api_chat_student_list.dart';

class ChatStudentListProvider extends GetxController {
  final student = <dynamic>[].obs;
  List data = [];
  String contentUrl = '';
  bool isLoading = true;
  bool hasMore = true;

  void getStudent(page, classesId, studyYear, searchKeyword) {
    // Prevent multiple simultaneous calls
    if (isLoading && page != 0) return;

    isLoading = true;
    if (page != 0) {
      update(); // Update UI to show loading indicator
    }

    Map data = {
      "class_school": classesId,
      "study_year": studyYear,
      "page": page,
      "search": searchKeyword == '' ? null : searchKeyword,
    };

    ChatStudentListAPI().getStudentList(data).then((res) {
      EasyLoading.dismiss();
      isLoading = false;

      if (!res['error']) {
        if (page == 0) {
          clear();
          changeContentUrl(res["content_url"]);
          student.value = res['results'];
          hasMore = res['results'].length > 0;
        } else {
          List temp = student.toList();
          temp.addAll(res['results']);
          student.value = temp;
          // Check if there's more data
          hasMore = res['results'].length > 0;
        }
        update();
      } else {
        EasyLoading.showError(res['message'].toString());
        update();
      }
    }).catchError((error) {
      EasyLoading.dismiss();
      isLoading = false;
      update();
    });
  }

  void changeContentUrl(String contentUrlx) {
    contentUrl = contentUrlx;
  }

  void changeLoading(bool isLoadingx) {
    isLoading = isLoadingx;
    update();
  }

  void clear() {
    student.value = [];
    hasMore = true;
    data.clear();
    update();
  }
}

class ChatGroupListProvider extends GetxController {
  List student = [];
  String contentUrl = '';
  void addStudent(List data) {
    student.addAll(data);
    update();
  }

  void changeContentUrl(String contentUrlx) {
    contentUrl = contentUrlx;
  }

  bool isLoading = true;
  void changeLoading(bool isLoadingx) {
    isLoading = isLoadingx;
    update();
  }

  void clear() {
    student.clear();
  }

  void changeReadingCount(String id) {
    student.where((element) => element['_id'] == id);
    final singleChat = student.firstWhere((item) => item['_id'] == id);
    singleChat['chats']['countUnRead'] = 0;
    update();
  }

  void addSingleChat(Map data, String id) {
    final singleChat = student.firstWhere((item) => item['_id'] == id);
    singleChat['chats']['data'] = [data];
    update();
  }
  //_data['chats']['data']
}
