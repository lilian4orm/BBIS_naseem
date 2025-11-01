import 'package:BBInaseem/screens/auth/accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api_connection/auth_connection.dart';
import '../../api_connection/student/api_dashboard_data.dart';
import '../../provider/auth_provider.dart';
import '../../provider/student/student_provider.dart';
import '../../provider/teacher/chat/chat_socket.dart';
import 'chat/chat_main/chat_main.dart';
import 'pages/degree/degree_choice.dart';
import 'pages/exam_schedule.dart';
import 'pages/notifications/notification_all.dart';
import 'pages/teacher_attend.dart';
import 'pages/teacher_salary/teacher_salary.dart';
import 'pages/teacher_weekly_schedule.dart';
import 'profile.dart';
import 'widgets/dialog_helpers.dart';
import 'widgets/latest_news_section.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/teacher_app_bar.dart';

class HomePageTeacher extends StatefulWidget {
  final Map userData;
  const HomePageTeacher({super.key, required this.userData});
  @override
  _HomePageTeacherState createState() => _HomePageTeacherState();
}

class _HomePageTeacherState extends State<HomePageTeacher> {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  final LatestNewsProvider latestNewsProvider = Get.put(LatestNewsProvider());

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Auth().getStudentInfo();
    Get.put(ChatSocketProvider()).changeSocket(dataProvider);
    DashboardDataAPI().latestNews();
  }

  List<QuickActionItem> _getQuickActions() {
    return [
      QuickActionItem(
        title: "chat".tr,
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFF6C63FF),
        onTap: () => Get.to(() => const ChatMain()),
      ),
      QuickActionItem(
        title: "salary".tr,
        icon: Icons.payments_outlined,
        color: const Color(0xFF00BFA5),
        onTap: () => Get.to(() => const TeacherSalary()),
      ),
      QuickActionItem(
        title: "com".tr,
        icon: Icons.how_to_reg_outlined,
        color: const Color(0xFFFF6B6B),
        onTap: () => Get.to(() => TeacherAttend(userData: widget.userData)),
      ),
      QuickActionItem(
        title: "notification".tr,
        icon: Icons.notifications_outlined,
        color: const Color(0xFFFFB300),
        onTap: () =>
            Get.to(() => NotificationTeacherAll(userData: widget.userData)),
      ),
      QuickActionItem(
        title: 'examTable'.tr,
        icon: Icons.calendar_today_outlined,
        color: const Color(0xFF7C4DFF),
        onTap: () => Get.to(() => const TeacherExamSchedule()),
      ),
      QuickActionItem(
        title: 'degrees'.tr,
        icon: Icons.grade_outlined,
        color: const Color(0xFFEC407A),
        onTap: () => Get.to(() => const DegreeChoice()),
      ),
      QuickActionItem(
        title: 'weeklyTable'.tr,
        icon: Icons.table_chart_outlined,
        color: const Color(0xFF26A69A),
        onTap: () => Get.to(() => const TeacherWeeklySchedule()),
      ),
      QuickActionItem(
        title: 'acounts'.tr,
        icon: Icons.person_outline_rounded,
        color: const Color(0xFF5C6BC0),
        onTap: () => Get.to(() => TeacherProfile(userData: widget.userData)),
      ),
      QuickActionItem(
        title: 'addAcount'.tr,
        icon: Icons.person_add_outlined,
        color: const Color(0xFF42A5F5),
        onTap: () => Get.to(() => const AccountsScreen()),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: GetBuilder<MainDataGetProvider>(
          builder: (_) => CustomScrollView(
            slivers: [
              TeacherAppBar(
                userName: widget.userData['account_name']?.toString() ?? '',
                onVersionTap: () => DialogHelpers.showVersionDialog(context),
                onLogoutTap: () => DialogHelpers.showLogoutDialog(context),
              ),
              const SliverToBoxAdapter(
                child: LatestNewsSection(),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: QuickActionsGrid(actions: _getQuickActions()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
