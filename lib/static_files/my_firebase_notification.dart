import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:BBInaseem/api_connection/auth_connection.dart';
import 'package:BBInaseem/init_data.dart';
import 'package:BBInaseem/screens/student/dashboard_student/chat/chat_main/chat_main.dart'
    as student;
import 'package:BBInaseem/screens/student/dashboard_student/student_attend.dart';
import 'package:BBInaseem/screens/teacher/chat/chat_main/chat_main.dart'
    as teacher;

import '../api_connection/student/api_dashboard_data.dart';
import '../provider/auth_provider.dart';
import '../screens/auth/login_page.dart';
import '../screens/student/dashboard_student/food_schedule.dart';
import '../screens/student/dashboard_student/notification_all.dart';
import '../screens/student/dashboard_student/student_salary/student_salary.dart';
import '../screens/student/dashboard_student/weekly_schedule.dart';
import '../screens/student/review/review_date.dart';
import '../screens/teacher/pages/notifications/notification_all.dart';
import '../screens/teacher/pages/teacher_weekly_schedule.dart';

class NotificationFirebase {
  initializeCloudMessage() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;   
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await messaging.subscribeToTopic('all');
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (notification) {
            Logger().i('From onDidReceiveNotificationResponse');
            //when app is open and click on notification
            receivedMessages(message);
          },
        );

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
    // FirebaseMessaging.onBackgroundMessage((message)async{
    //   receivedMessages(message);
    // });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      //when app is running but in the background and click on notification
      receivedMessages(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      //when app is terminated and click on notification
      Logger().i('From getInitialMessage');
      if (message != null) {
        await init();
        await Auth().getStudentInfo();
        receivedMessages(message);
      }
    });
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

receivedMessages(RemoteMessage message) {
  final box = GetStorage();
  Map? userData = box.read('_userData');
  Logger().i(message.data);
  if (userData != null) {
    Get.put(TokenProvider()).addToken(userData);
  }

  if (userData == null) {
    return const LoginPage();
  } else if (userData["account_type"] == "student") {
    Logger().i(message.data);
    if (message.data['type'] == 'news') {
      DashboardDataAPI().latestNews(); //update news
    }
    if (message.data['type'] == 'schedule') {
      Get.to(() => const WeeklySchedule());
    } else if (message.data['type'] == 'scheduleFood') {
      Get.to(() => const FoodSchedule());
    } else if (message.data['type'] == 'scheduleFood') {
      Get.to(() => const FoodSchedule());
    } else if (message.data['type'] == 'review') {
      Get.to(() => const ReviewDate());
    } else if (message.data['type'] == 'notification') {
      Get.to(() => NotificationAll(userData: userData));
    } else if (message.data['type'] == 'installments') {
      Get.to(() => const StudentSalary());
    } else if (message.data['type'] == 'message') {
      Get.to(() => const student.ChatMain());
    } else if (message.data['type'] == 'absence') {
      Get.to(() => StudentAttend(userData: userData));
    } else {
      return const LoginPage();
    }
  } else if (userData["account_type"] == "driver") {
  } else if (userData["account_type"] == "teacher") {
    if (message.data['type'] == 'news') {
      DashboardDataAPI().latestNews(); //update news
    }
    if (message.data['type'] == 'schedule') {
      Get.to(() => const TeacherWeeklySchedule());
    } else if (message.data['type'] == 'notification') {
      Get.to(() => NotificationTeacherAll(userData: userData));
    } else if (message.data['type'] == 'message') {
      Get.to(() => const teacher.ChatMain());
    }
  } else {
    return const LoginPage();
  }
}
