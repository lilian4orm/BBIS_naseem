import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/teacher/chat/chat_all_list_items.dart';
import '../../../provider/teacher/chat/chat_message.dart';
import '../../../provider/teacher/chat/chat_socket.dart';
import '../../../static_files/debouncer.dart';
import '../../../static_files/my_chat_static_files.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import '../../../static_files/my_times.dart';
import 'chat_main/chat_page.dart';

class ChatStudentList extends StatefulWidget {
  const ChatStudentList({super.key});

  @override
  State<ChatStudentList> createState() => _ChatStudentListState();
}

class _ChatStudentListState extends State<ChatStudentList> {
  final MainDataGetProvider _mainDataGetProvider =
      Get.put(MainDataGetProvider());
  final ScrollController _scrollController = ScrollController();
  final List _classes =
      Get.put(MainDataGetProvider()).mainData['account']['account_division'];
  final TextEditingController searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 600));
  final ChatStudentListProvider chatStudentProvider = Get.find();

  int page = 0;
  final List _classesId = [];
  late String _studyYear;

  search() {
    page = 0;
    EasyLoading.show(status: 'getData'.tr);
    chatStudentProvider.getStudent(
        page, _classesId, _studyYear, searchController.text);
  }

  _getStudentList() {
    _studyYear = _mainDataGetProvider.mainData['setting'][0]['setting_year'];
    if (page != 0) {
      EasyLoading.show(status: 'getData'.tr);
    }
    chatStudentProvider.getStudent(
        page, _classesId, _studyYear, searchController.text);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (Map _data in _classes) {
      _classesId.add(_data['_id'].toString());
    }
    _getStudentList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Only load more if not already loading and there's more data
        if (!chatStudentProvider.isLoading && chatStudentProvider.hasMore) {
          page++;
          _getStudentList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatStudentListProvider>(builder: (val) {
      return val.student.toList().isEmpty && val.isLoading
          ? Center(
              child: loadingChat(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 0, right: 20, left: 20),
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
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      if (index == val.student.toList().length &&
                          val.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (index < val.student.toList().length) {
                        return _student(
                            val.student.toList()[index], val.contentUrl);
                      }
                      return const SizedBox.shrink();
                    },
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount:
                        val.student.toList().length + (val.isLoading ? 1 : 0),
                  ),
                ),
              ],
            );
    });
  }

  Widget _student(Map data, String contentUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              data['account_name'].toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: data['chats']['data'].length == 0
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
                              data['chats']['data'][0]
                                      ['chat_message_is_deleted']
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
              Get.put(ChatMessageProvider()).clear();
              Get.put(ChatMessageProvider()).addListChat(data['chats']['data']);
              await Get.to(
                  () => ChatPage(userInfo: data, contentUrl: contentUrl));
              Get.put(ChatSocketProvider())
                  .socket
                  .emit('readMessage', data['_id']);
              Get.put(ChatMessageProvider()).isShow(false);
              page = 0;
              _getStudentList();
            },
            onLongPress: () {
              _showBottomSheet(data, context);
            },
          ),
          Wrap(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: Text(data['class_name']),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: Text(data['section_name']),
              )
            ],
          )
        ],
      ),
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

void _showBottomSheet(Map data, BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return _bottomSheet(data);
    },
  );
}

Widget _bottomSheet(Map data) {
  return Container(
      decoration: const BoxDecoration(
        color: MyColor.white1,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: GetBuilder<MainDataGetProvider>(builder: (_) {
        return Column(
          children: [
            ListTile(
              title: Text(
                data['account_name'].toString(),
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                '${_.mainData['account']["account_division_current"]['class_name']} - ${_.mainData['account']["account_division_current"]['leader']}',
                style: const TextStyle(
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(),
          ],
        );
      }));
}
