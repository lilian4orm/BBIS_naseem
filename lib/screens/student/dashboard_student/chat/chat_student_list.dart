import 'package:empty_widget_pro/empty_widget_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/student/chat/chat_all_list_items.dart';
import '../../../../provider/student/chat/chat_message.dart';
import '../../../../provider/student/chat/chat_socket.dart';
import '../../../../static_files/debouncer.dart';
import '../../../../static_files/my_chat_static_files.dart';
import '../../../../static_files/my_color.dart';
import '../../../../static_files/my_loading.dart';
import '../../../../static_files/my_times.dart';
import 'chat_main/chat_page.dart';

class ChatTeacherList extends StatefulWidget {
  const ChatTeacherList({super.key});

  @override
  State<ChatTeacherList> createState() => _ChatTeacherListState();
}

class _ChatTeacherListState extends State<ChatTeacherList> {
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  final ScrollController _scrollController = ScrollController();
  // final List _classes = Get
  //     .put(MainDataGetProvider())
  //     .mainData['account']['account_division'];

  int page = 0;
  final TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 600));

  final ChatTeacherListProvider chatTeacherProvider = Get.find();

  final String _classesId = Get.put(MainDataGetProvider()).mainData['account']
      ['account_division_current']['_id'];
  late String _studyYear;

  search() {
    page = 0;

    EasyLoading.show(status: 'getData'.tr);
    chatTeacherProvider.getStudent(
        page, _classesId, _studyYear, searchController.text);
  }

  _getTeacherList() {
    _studyYear = _mainDataGetProvider.mainData['setting'][0]['setting_year'];
    if (page != 0) {
      EasyLoading.show(status: 'getData'.tr);
    }
    chatTeacherProvider.getStudent(
        page, _classesId, _studyYear, searchController.text);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _getTeacherList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++;
        _getTeacherList();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatTeacherListProvider>(builder: (val) {
      return val.isLoading
          ? Center(
              child: loadingChat(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 10, right: 20, left: 20),
                    child: TextFormField(
                      controller: searchController,
                      style: const TextStyle(
                        color: MyColor.black,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24),
                        errorStyle: const TextStyle(color: MyColor.grayDark),
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        suffixIcon: const Icon(Icons.search),
                        filled: true,
                        hintText: 'search'.tr,
                      ),
                      onChanged: (keyword) {
                        _debouncer(() {
                          search();
                        });
                      },
                      onTapOutside: (e) {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  val.student.isEmpty
                      ? EmptyWidget(
                          image: null,
                          packageImage: PackageImage.Image_4,
                          title: 'nodta'.tr,
                          subTitle: 'nodta'.tr,
                          titleTextStyle: const TextStyle(
                            fontSize: 22,
                            color: MyColor.black,
                            fontWeight: FontWeight.w500,
                          ),
                          subtitleTextStyle: const TextStyle(
                            fontSize: 14,
                            color: MyColor.black,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: Get.width,
                              height: Get.height - 200,
                              child: ListView.builder(
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          _student(
                                              val.student[index],
                                              val.contentUrl,
                                              val.isChatOpen.value),
                                  controller: _scrollController,
                                  //separatorBuilder: (BuildContext context, int index)=>const Divider(),
                                  padding: const EdgeInsets.only(top: 10),
                                  itemCount: val.student.length),
                            ),
                          ],
                        )
                ],
              ),
            );
    });
  }

  _student(Map data, String contentUrl, bool isChatOpen) {
    return ListTile(
      title: Text(
        data['account_name'].toString(),
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: data['chats']['data'].length == 0
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
                    decoration: data['chats']['data'][0]
                            ['chat_message_is_deleted']
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1.0,
                              color: Colors.grey.shade300,
                            ),
                          )
                        : null,
                    child: Text(
                        data['chats']['data'][0]['chat_message_is_deleted']
                            ? 'msgDeleted'.tr
                            : data['chats']['data'][0]['chat_message'] ??
                                'fileSended'.tr,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: data['chats']['data'][0]
                                    ['chat_message_isRead']
                                ? FontWeight.normal
                                : FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
      leading: profileImg(contentUrl, data['account_img']),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (data['chats']['data'].isNotEmpty)
            _timeText(data['chats']['data'][0]['created_at']),
          if (data['chats']['countUnRead'] > 0)
            _messageUnRead(data['chats']['countUnRead']),
        ],
      ),
      onTap: () async {
        searchController.clear();
        Get.put(ChatMessageStudentProvider()).clear();
        Get.put(ChatMessageStudentProvider())
            .addListChat(data['chats']['data']);
        await Get.to(() => ChatPage(
            userInfo: data, contentUrl: contentUrl, isChatOpen: isChatOpen));
        Get.put(ChatSocketStudentProvider())
            .socket
            .emit('readMessage', data['_id']);
        Get.put(ChatMessageStudentProvider()).isShow(false);
        page = 0;
        _getTeacherList();
      },
      onLongPress: () {
        Get.bottomSheet(_bottomSheet(data));
      },
    );
  }
}

Text _timeText(int time) {
  return Text(
    getChatDate(time, 12),
    style: const TextStyle(fontSize: 10),
  );
}

Widget _messageUnRead(int count) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: MyColor.green,
    ),
    padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
    child: count > 99
        ? const Text(
            "99+",
            style: TextStyle(fontSize: 10, color: MyColor.white0),
          )
        : Text(
            count.toString(),
            style: const TextStyle(fontSize: 10, color: MyColor.white0),
          ),
  );
}

Widget _bottomSheet(Map data) {
  return Container(
    decoration: const BoxDecoration(
        color: MyColor.white1,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), topLeft: Radius.circular(10))),
    child: Column(
      children: [
        ListTile(
          title: Text(
            data['account_name'].toString(),
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
              '${data['account_division_current']['class_name']} - ${data['account_division_current']['leader']}',
              style: const TextStyle(
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const Divider(),
      ],
    ),
  );
}
