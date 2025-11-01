import 'package:BBInaseem/local_database/models/account.dart';
import 'package:BBInaseem/provider/accounts_provider.dart';
import 'package:BBInaseem/screens/auth/accounts_screen.dart';
import 'package:BBInaseem/screens/auth/login_page.dart';
import 'package:BBInaseem/static_files/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';

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
  final AccountProvider accountProvider = Get.put(AccountProvider());
  TokenProvider get tokenProvider => Get.put(TokenProvider());
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

  onOtherAccountFound(Map<String, dynamic> account) async {
    await accountProvider.onClickAccount(account);
    tokenProvider.addToken(account);
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (!isIOS) {
      Restart.restartApp();
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('confirm'.tr),
            content: Text(
              'reloadApp'.tr,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () {
                  Restart.restartApp();
                },
                child: Text('confirm'.tr),
              ),
            ],
          );
        },
      );
    }
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
                  onLogoutTap: () {
                    Get.defaultDialog(
                        title: 'logout'.tr,
                        content: Text(
                          'confirmLogout'.tr,
                        ),
                        cancel: MaterialButton(
                          color: MyColor.purple,
                          onPressed: () => Get.back(),
                          child: Text(
                            "cancel".tr,
                            style: const TextStyle(color: MyColor.yellow),
                          ),
                        ),
                        confirm: MaterialButton(
                            color: MyColor.red,
                            child: Text(
                              "confirm".tr,
                              style: const TextStyle(color: MyColor.white1),
                            ),
                            onPressed: () {
                              Auth().loginOut().then((res) async {
                                if (res['error'] == false) {
                                  Account accountToDelete = Account.fromMap(
                                      Map<String, dynamic>.from(
                                          widget.userData));

                                  await accountProvider
                                      .deleteAccount(accountToDelete);

                                  if (accountProvider.accounts.firstOrNull !=
                                      null) {
                                    onOtherAccountFound(
                                        accountProvider.accounts.first.toMap());
                                  } else {
                                    Get.offAll(() => const LoginPage());

                                    EasyLoading.showSuccess(
                                        res['message'].toString());
                                  }
                                } else {
                                  EasyLoading.showError(
                                      res['message'].toString());
                                }
                              });
                            }));
                  }),
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
