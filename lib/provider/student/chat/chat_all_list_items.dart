import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../../api_connection/student/chat/api_chat_student_list.dart';

class ChatTeacherListProvider extends GetxController {
  RxList student = [].obs;
  String contentUrl = '';
  List data = [];
  RxBool isChatOpen = false.obs;
  bool isFetching = false;
  int _requestSeq = 0;
  void getStudent(page, classesId, studyYear, searchKeyword) {
    if (isFetching) return;
    isFetching = true;
    final int seq = ++_requestSeq;
    Logger().i(searchKeyword);
    Map data = {
      "class_school": classesId,
      "study_year": studyYear,
      "page": page,
      "search": searchKeyword == '' ? null : searchKeyword,
    };

    ChatTeacherListAPI().getStudentList(data).then((res) {
      if (seq != _requestSeq) return; // ignore stale responses
      EasyLoading.dismiss();
      if (!res['error']) {
        if (res['is_chat_open'] is bool) {
          isChatOpen.value = res['is_chat_open'];
          update();
        }
        if (page == 0) {
          clear();
          changeContentUrl(res["content_url"]);
          changeLoading(false);
          student.value = res['results'];
          update();
        } else {
          List temp = student;
          temp.addAll(res['results']);
          student.value = temp;
        }
        update();
      } else {
        EasyLoading.showError(res['message'].toString());
      }
    }).whenComplete(() {
      isFetching = false;
    });
  }

  void changeContentUrl(String contentUrlR) {
    contentUrl = contentUrlR;
  }

  bool isLoading = true;
  void changeLoading(bool isLoadingR) {
    isLoading = isLoadingR;
  }

  void clear() {
    student.value = [];
    update();
    data.clear();
  }
}

class ChatGroupStudentListProvider extends GetxController {
  List student = [];
  String contentUrl = '';
  RxBool isChatOpen = false.obs;

  void addStudent(List data) {
    student.addAll(data);
    update();
  }

  void changeIsOpenState(bool isOpen) {
    isChatOpen.value = isOpen;
  }

  void changeContentUrl(String contentUrlR) {
    contentUrl = contentUrlR;
  }

  bool isLoading = true;
  void changeLoading(bool isLoadingR) {
    isLoading = isLoadingR;
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
