import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart' as intl;
import 'package:BBInaseem/provider/locale_controller.dart';
import 'package:BBInaseem/provider/student/subjects_provider.dart';
import 'package:BBInaseem/provider/teacher/provider_teacher_dashboard.dart';
import 'provider/auth_provider.dart';
import 'provider/driver/provider_maps.dart';
import 'provider/driver/provider_notification.dart';
import 'provider/driver/provider_rides_students.dart';
import 'provider/provider_audio_player.dart';
import 'provider/student/attend_provider.dart';
import 'provider/student/chat/chat_all_list_items.dart';
import 'provider/student/chat/chat_message.dart';
import 'provider/student/chat/chat_socket.dart';
import 'provider/student/food_schedule_provider.dart';
import 'provider/student/provider_daily_exams.dart';
import 'provider/student/provider_degree.dart';
import 'provider/student/provider_genral_data.dart';
import 'provider/student/provider_maps.dart';
import 'provider/student/provider_notification.dart';
import 'provider/student/provider_review.dart';
import 'provider/student/provider_ride.dart';
import 'provider/student/provider_salary.dart';
import 'provider/student/provider_student_dashboard.dart';
import 'provider/student/student_provider.dart';
import 'provider/student/weekly_schedule_provider.dart';
import 'provider/teacher/chat/chat_all_list_items.dart';
import 'provider/teacher/chat/chat_message.dart';
import 'provider/teacher/chat/chat_socket.dart';
import 'provider/teacher/chat/image_provider.dart';
import 'provider/teacher/provider_attend.dart';
import 'provider/teacher/provider_degree_teacher.dart';
import 'provider/teacher/provider_notification.dart';
import 'provider/teacher/provider_salary.dart';
import 'provider/teacher/provider_weekly_schedule.dart';
import 'static_files/my_firebase_notification.dart';

Future<void> init() async {
  await Firebase.initializeApp();
  await GetStorage.init();
  if (intl.Intl.defaultLocale != "en_US") {
    intl.Intl.defaultLocale = "en_US";
  }
  setup();
  await NotificationFirebase().initializeCloudMessage();
}

void setup() {
  // language
  Get.put(MylocaleController());

  //GeneralData().getClasses();
  ///general stateManagement
  Get.put(TokenProvider());
  Get.put(MainDataGetProvider());
  Get.put(AdsProvider());
  Get.put(ContactProvider());

  Get.put(AudioPlayerProvider());

  ///student stateManagement
  Get.put(StudentDashboardProvider());
  Get.put(DailyExamsProvider());
  Get.put(SubjectProvider());
  Get.put(AreasProvider());

  Get.put(StudentSalaryProvider());
  Get.put(NotificationProvider());
  Get.put(NotificationProviderE());
  Get.put(LatestNewsProvider());
  Get.put(DegreeProvider());
  Get.put(ExamsProvider());
  Get.put(StudentAttendProvider());
  Get.put(StudentRideProvider());
  Get.put(WeeklyScheduleProvider());
  Get.put(SubjectsProvider());
  Get.put(FoodScheduleProvider());
  Get.put(ReviewDateProvider());
  Get.put(SocketDataProvider());
  Get.put(MapStudentProvider());
  Get.put(ChatTeacherListProvider());
  Get.put(ChatMessageBottomBarStudentProvider());
  Get.put(ChatMessageStudentProvider());
  Get.put(ChatMessageGroupStudentProvider());
  Get.put(ChatSocketStudentProvider());
  Get.put(ChatGroupStudentListProvider());
  Get.put(StudentFullSalaryProvider());

  ///teacher stateManagement
  Get.put(TeacherDashboardProvider());
  Get.put(TeacherAttendProvider());
  Get.put(TeacherWeeklyScheduleProvider());
  Get.put(TeacherNotificationProvider());
  Get.put(TeacherHomeworkAnswersProvider());
  Get.put(SelectSwitchProvider());
  Get.put(ExamsTeacherProvider());
  Get.put(DegreeTeacherProvider());
  Get.put(TeacherSalaryProvider());
  Get.put(DegreeTeacherStudentListProvider());
  Get.put(TeacherFullSalaryProvider());

  //chat
  Get.put(ChatStudentListProvider());
  Get.put(ChatGroupListProvider());
  Get.put(ChatMessageBottomBarProvider());
  Get.put(ChatSocketProvider());
  Get.put(ImageGroupProvider());

  //chat
  ///driver stateManagement
  Get.put(RidesStudentsProvider());
  Get.put(MapDataProvider());
  Get.put(NotificationDriverProvider());
  Get.put(ChatMessageProvider());
}
