import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:BBInaseem/provider/auth_provider.dart';
import 'package:BBInaseem/provider/teacher/chat/chat_socket.dart';
import '../../../../static_files/my_color.dart';
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
    Get.put(ChatSocketProvider()).changeSocket(dataProvider);
    Get.put(ChatSocketProvider()).socket.connect();
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
    Get.put(ChatSocketProvider()).socket.disconnect();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Get.put(ChatSocketProvider()).socket.connect();
        Logger().i("app in resumed");
        break;
      case AppLifecycleState.inactive:
        Get.put(ChatSocketProvider()).socket.disconnect();
        Logger().i("app in inactive");
        break;
      case AppLifecycleState.paused:
        Get.put(ChatSocketProvider()).socket.disconnect();
        Logger().i("app in paused");
        break;
      case AppLifecycleState.detached:
        Get.put(ChatSocketProvider()).socket.disconnect();
        Logger().i("app in detached");
        break;

      case AppLifecycleState.hidden:
        Logger().i("app in hidden");
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
                  title: Text('CHAT'.tr),
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    labelColor: MyColor.white0,
                    unselectedLabelColor: MyColor.white0,
                    indicatorColor: MyColor.white0,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        text: "students".tr,
                      ),
                      // Tab(
                      //   text: "الصفوف",
                      // ),
                      // Tab(
                      //   text: "groups".tr,
                      // ),
                    ],
                  ),
                ),
              ];
            },
            body: const TabBarView(
              children: [
                ChatStudentList(),
                //ChatClassGroupList(),
                // ChatGroupList(),
              ],
            )),
      ),
    );
  }
}
