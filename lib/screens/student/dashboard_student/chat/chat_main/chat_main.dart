import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:BBInaseem/provider/auth_provider.dart';
import 'package:BBInaseem/provider/student/chat/chat_socket.dart';

import '../../../../../static_files/my_color.dart';
import '../chat_student_list.dart';

class ChatMain extends StatefulWidget {
  const ChatMain({super.key});

  @override
  State<ChatMain> createState() => _ChatMainState();
}

class _ChatMainState extends State<ChatMain> with WidgetsBindingObserver {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Get.put(ChatSocketStudentProvider()).changeSocket(dataProvider);
    Get.put(ChatSocketStudentProvider()).socket.connect();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    Logger().i("out the chat");
    Get.put(ChatSocketStudentProvider()).socket.disconnect();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Get.put(ChatSocketStudentProvider()).socket.connect();
        break;
      case AppLifecycleState.inactive:
        Get.put(ChatSocketStudentProvider()).socket.disconnect();
        break;
      case AppLifecycleState.paused:
        Get.put(ChatSocketStudentProvider()).socket.disconnect();
        break;
      case AppLifecycleState.detached:
        break;

      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: MyColor.purple,
                  foregroundColor: MyColor.white0,
                  title: Text("chat".tr),
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    labelColor: MyColor.white0,
                    unselectedLabelColor: MyColor.white0,
                    indicatorColor: MyColor.white0,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        text: 'teachers'.tr,
                      ),
                      // Tab(
                      //   text: "الصفوف",
                      // ),
                      // Tab(
                      //   text: 'groups'.tr,
                      // ),
                    ],
                  ),
                ),
              ];
            },
            body: const TabBarView(
              children: [
                ChatTeacherList(),
                //ChatClassGroupList(),
                // ChatGroupList(),
              ],
            )),
      ),
    );
  }
}
