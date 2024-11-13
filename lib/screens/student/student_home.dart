import 'package:BBInaseem/main.dart';
import 'package:BBInaseem/screens/student/guest_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:BBInaseem/provider/student/provider_maps.dart';
import 'package:BBInaseem/static_files/my_url.dart';
import '../../api_connection/auth_connection.dart';
import '../../provider/auth_provider.dart';
import '../../provider/student/provider_student_dashboard.dart';
import '../../provider/student/student_provider.dart';
import '../../static_files/my_color.dart';
import '../../static_files/my_loading.dart';
import 'dashboard_student/daily_exams.dart';
import 'dashboard_student/dashboard.dart';
import 'profile/student_profile.dart';
import 'review/review_date.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomePageStudent extends StatefulWidget {
  final Map userData;
  const HomePageStudent({super.key, required this.userData});
  @override
  HomePageStudentState createState() => HomePageStudentState();
}

class HomePageStudentState extends State<HomePageStudent>
    with AutomaticKeepAliveClientMixin {
  final LatestNewsProvider latestNewsProvider = Get.put(LatestNewsProvider());
  final StudentDashboardProvider studentDashboardProvider =
      Get.put(StudentDashboardProvider());
  late IO.Socket socket;
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  final SocketDataProvider _socketDataProvider = Get.put(SocketDataProvider());
  initSocketDriver() {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    socket = IO.io(
        '${socketURL}driver',
        IO.OptionBuilder()
            .disableAutoConnect()
            .setTransports(['websocket'])
            .setAuth(headers)
            .build());
    _socketDataProvider.changeSocket(socket);
  }

  void _onItemTapped(int index) {
    studentDashboardProvider.changeIndex(index);
  }

  void initWidgetList() {
    List<Widget> widgetList = <Widget>[
      Dashboard(userData: widget.userData),
      const ReviewDate(),
      const DailyExams(),
      StudentProfile(userData: widget.userData),
    ];
    studentDashboardProvider.initWidget(widgetList);
  }

  initUserData() async {
    await Auth().getStudentInfo();
    // Get.put(ChatSocketStudentProvider()).changeSocket(dataProvider);
    initSocketDriver();
    initWidgetList();
  }

  @override
  void initState() {
    if (sharePref.getString('guest') == null) {
      initUserData();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GetBuilder<StudentDashboardProvider>(builder: (val) {
        return Container(
          child: sharePref.getString('guest') == 'guest'
              ? const GuestWidget()
              : val.widgetOptions == null
                  ? loading()
                  : val.widgetOptions![val.selectedIndex],
        );
      }),
      bottomNavigationBar: GetBuilder<StudentDashboardProvider>(builder: (val) {
        return BottomNavigationBar(
          unselectedItemColor: MyColor.purple.withOpacity(0.6),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(CommunityMaterialIcons.home_outline),
              label: 'main'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CommunityMaterialIcons.diamond_outline),
              label: 'stD'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CommunityMaterialIcons.file_outline),
              label: 'dailyExam'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(LineIcons.user),
              label: 'acou'.tr,
            ),
          ],
          currentIndex: val.selectedIndex,
          selectedItemColor: MyColor.purple,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
