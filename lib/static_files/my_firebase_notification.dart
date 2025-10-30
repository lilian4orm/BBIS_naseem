import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:BBInaseem/provider/student/chat/chat_all_list_items.dart'
    as student_list;
import 'package:BBInaseem/provider/teacher/chat/chat_all_list_items.dart'
    as teacher_list;
import 'package:BBInaseem/api_connection/auth_connection.dart';
import 'package:BBInaseem/init_data.dart';
import 'package:BBInaseem/screens/student/dashboard_student/chat/chat_main/chat_main.dart'
    as student;
import 'package:BBInaseem/screens/student/dashboard_student/chat/chat_main/chat_page.dart'
    as student_chat;
import 'package:BBInaseem/screens/student/dashboard_student/student_attend.dart';
import 'package:BBInaseem/screens/teacher/chat/chat_main/chat_main.dart'
    as teacher;
import 'package:BBInaseem/screens/teacher/chat/chat_main/chat_page.dart'
    as teacher_chat;

import '../api_connection/student/api_dashboard_data.dart';
import '../api_connection/student/api_notification.dart';
import '../provider/auth_provider.dart';
import '../screens/auth/login_page.dart';
import '../screens/student/dashboard_student/food_schedule.dart';
import '../screens/student/dashboard_student/student_salary/student_salary.dart';
import '../screens/student/dashboard_student/weekly_schedule.dart';
import '../screens/student/review/review_date.dart';
import '../screens/teacher/pages/teacher_weekly_schedule.dart';
import '../screens/student/dashboard_student/show/show_message.dart' as student_show;
import '../screens/teacher/pages/notifications/show/show_message.dart' as teacher_show;
import '../screens/driver/notifications/show_message.dart' as driver_show;

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

    // Log current token and resubscribe on refresh
    try {
      final token = await messaging.getToken();
      Logger().i('FCM token: $token');
    } catch (e) {
      Logger().w('Failed to get FCM token: $e');
    }
    messaging.onTokenRefresh.listen((newToken) async {
      Logger().i('FCM token refreshed: $newToken');
      // Try to re-follow topics when token changes (if user is logged in)
      final box = GetStorage();
      final Map? userData = box.read('_userData');
      if (userData != null) {
        try {
          await Auth().getStudentInfo(); // refresh and followTopics() inside
        } catch (e) {
          Logger().w('Failed to refresh topics after token refresh: $e');
        }
      }
    });

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
          payload: jsonEncode(message.data),
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
        // Delay navigation to ensure app is fully ready
        Future.delayed(const Duration(milliseconds: 500), () {
          receivedMessages(message);
        });
      }
    });
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

receivedMessages(RemoteMessage message) async {
  final box = GetStorage();
  Map? userData = box.read('_userData');
  
  // Debug: Log all message data
  Logger().i('=== FIREBASE MESSAGE DEBUG ===');
  Logger().i('message.data: ${message.data}');
  Logger().i('message.notification: ${message.notification}');
  Logger().i('message.notification?.title: ${message.notification?.title}');
  Logger().i('message.notification?.body: ${message.notification?.body}');
  Logger().i('message.data[title]: ${message.data['title']}');
  Logger().i('message.data[body]: ${message.data['body']}');
  Logger().i('message.data[type]: ${message.data['type']}');
  Logger().i('================================');
  
  // Check if message has data
  final notificationType = message.data['type'] as String?;
  final notificationId = message.data['id'] as String?;
  
  // Also check for alternative type fields
  final altType1 = message.data['notification_type'] as String?;
  final altType2 = message.data['notifications_type'] as String?;
  
  Logger().i('Original type: $notificationType');
  Logger().i('Alt type 1: $altType1');
  Logger().i('Alt type 2: $altType2');
  
  // Extract title and description from notification data
  // Priority: data fields > notification fields > defaults
  String notificationTitle = message.data['notifications_title'] ?? 
                            message.data['title'] ?? 
                            message.notification?.title ?? 
                            'إشعار';
  String notificationBody = message.data['notifications_description'] ?? 
                           message.data['body'] ?? 
                           message.notification?.body ?? 
                           '';
  
  // Determine the actual notification type
  String? actualType = notificationType ?? altType1 ?? altType2;
  
  Logger().i('Final Title: $notificationTitle');
  Logger().i('Final Body: $notificationBody');
  Logger().i('Notification Type: $notificationType');
  Logger().i('Actual Type: $actualType');
  Logger().i('Is Message Type: ${actualType == 'message'}');
  
  if (userData != null) {
    Get.put(TokenProvider()).addToken(userData);
  }

  // If user is not logged in, redirect to login page
  if (userData == null) {
    Get.offAll(() => const LoginPage());
    return;
  }

  // Wait for GetMaterialApp to be ready if navigating from terminated state
  await Future.delayed(const Duration(milliseconds: 300));

  // Create notification data for ShowMessage
  Map notificationData = {
    '_id': notificationId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    'notifications_title': notificationTitle,
    'notifications_description': notificationBody,
    'notifications_type': actualType ?? 'إشعار',
    'notifications_link': message.data['link'] ?? '',
    'notifications_imgs': message.data['images'] ?? null,
    'notifications_sender': message.data['sender'] ?? null,
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'isRead': false,
  };

  // Extract sender info for chat (supports Map or JSON String)
  Map? senderInfo;
  try {
    final dynamic rawSender = message.data['sender_info'];
    if (rawSender != null) {
      if (rawSender is Map) {
        senderInfo = Map.from(rawSender);
      } else if (rawSender is String && rawSender.isNotEmpty) {
        final decoded = jsonDecode(rawSender);
        if (decoded is Map) {
          senderInfo = Map.from(decoded);
        }
      }
    }
  } catch (e) {
    Logger().w('Failed to parse sender_info: $e');
  }

  // Fallbacks for common alternate payload structures
  senderInfo ??= _buildSenderInfoFallback(message.data);
  
  Logger().i('Sender Info: $senderInfo');
  Logger().i('Sender Info Type: ${senderInfo?.runtimeType}');

  // Debug logging to ensure data is correct
  Logger().i('Notification Title: $notificationTitle');
  Logger().i('Notification Description: $notificationBody');
  Logger().i('Full notification data: $notificationData');

  String contentUrl = message.data['content_url'] ?? '';

  // Handle notifications based on user type
  if (userData["account_type"] == "student") {
    Logger().i('Student notification, type: $actualType');
    
    // Check for message type first
    if (actualType == 'message') {
      Logger().i('Opening chat for student');
      Logger().i('Sender Info is null: ${senderInfo == null}');
      if (senderInfo != null) {
        // Open specific chat with sender
        Logger().i('Opening specific chat with sender: ${senderInfo['_id']}');
        Logger().i('Sender Info Keys: ${senderInfo.keys.toList()}');
        try {
          Get.offAll(() => student_chat.ChatPage(
            userInfo: Map.from(senderInfo!),
            contentUrl: contentUrl,
            isChatOpen: true,
          ));
          Logger().i('Successfully opened specific chat');
        } catch (e) {
          Logger().i('Error opening specific chat: $e');
          // Fallback to general chat
          Get.offAll(() => const student.ChatMain());
        }
      } else {
        // Open general chat list
        Logger().i('Opening general chat list');
        Get.offAll(() => const student.ChatMain());
      }
      return;
    }
    
    if (actualType == 'news') {
      DashboardDataAPI().latestNews(); //update news
      return;
    }
    if (actualType == 'schedule') {
      Get.offAll(() => const WeeklySchedule());
    } else if (actualType == 'scheduleFood') {
      Get.offAll(() => const FoodSchedule());
    } else if (actualType == 'review') {
      Get.offAll(() => const ReviewDate());
    } else if (actualType == 'installments') {
      Get.offAll(() => const StudentSalary());
    } else if (actualType == 'absence') {
      Get.offAll(() => StudentAttend(userData: userData));
    } else {
      // Try to infer chat by matching notification title with chat list names
      if (message.notification != null && notificationTitle.isNotEmpty) {
        final matched = await _tryLoadAndOpenByTitle(
            userType: 'student', title: notificationTitle);
        if (matched) return;
      }
      // For all other notification types, open ShowMessage
      Logger().i('Opening ShowMessage for student');
      Get.to(() => student_show.ShowMessage(
        data: notificationData,
        contentUrl: contentUrl,
        notificationsType: notificationData['notifications_type'],
        onUpdate: () {
          Logger().i('Notification updated');
          // Update read status like in notification list
          NotificationsAPI().updateReadNotifications(notificationData['_id']);
        },
      ));
    }
  } else if (userData["account_type"] == "driver") {
    // Handle driver notifications - drivers don't have separate chat page
    // All notifications open ShowMessage for drivers
    Get.to(() => driver_show.ShowMessage(
      data: notificationData,
      contentUrl: contentUrl,
      notificationsType: notificationData['notifications_type'],
    ));
  } else if (userData["account_type"] == "teacher") {
    Logger().i('Teacher notification, type: $actualType');
    
    // Check for message type first
    if (actualType == 'message') {
      Logger().i('Opening chat for teacher');
      Logger().i('Sender Info is null: ${senderInfo == null}');
      if (senderInfo != null) {
        // Open specific chat with sender
        Logger().i('Opening specific chat with sender: ${senderInfo['_id']}');
        Logger().i('Sender Info Keys: ${senderInfo.keys.toList()}');
        try {
          Get.offAll(() => teacher_chat.ChatPage(
            userInfo: Map.from(senderInfo!),
            contentUrl: contentUrl,
          ));
          Logger().i('Successfully opened specific chat');
        } catch (e) {
          Logger().i('Error opening specific chat: $e');
          // Fallback to general chat
          Get.offAll(() => const teacher.ChatMain());
        }
      } else {
        // Open general chat list
        Logger().i('Opening general chat list');
        Get.offAll(() => const teacher.ChatMain());
      }
      return;
    }
    
    if (actualType == 'news') {
      DashboardDataAPI().latestNews(); //update news
      return;
    }
    if (actualType == 'schedule') {
      Get.offAll(() => const TeacherWeeklySchedule());
    } else {
      // Try to infer chat by matching notification title with chat list names
      if (message.notification != null && notificationTitle.isNotEmpty) {
        final matched = await _tryLoadAndOpenByTitle(
            userType: 'teacher', title: notificationTitle);
        if (matched) return;
      }
      // For all other notification types, open ShowMessage
      Logger().i('Opening ShowMessage for teacher');
      Get.to(() => teacher_show.ShowMessage(
        data: notificationData,
        contentUrl: contentUrl,
        notificationsType: notificationData['notifications_type'],
      ));
    }
  } else {
    // If account type is unknown, redirect to login page
    Get.offAll(() => const LoginPage());
  }
}

// Attempt to construct a minimal sender info map from alternative keys
Map<String, dynamic>? _buildSenderInfoFallback(Map data) {
  try {
    final senderId = data['sender_id'] ?? data['from_id'] ?? data['user_id'];
    final senderName = data['sender_name'] ?? data['from_name'] ?? data['name'];
    final senderAvatar = data['sender_avatar'] ?? data['avatar'] ?? data['image'];
    if (senderId != null) {
      return {
        '_id': senderId,
        'name': senderName ?? 'user',
        'image': senderAvatar,
      };
    }
  } catch (_) {}
  return null;
}

// Try to open a chat by matching notification title with existing chat list
bool _openChatByTitleIfPossible({required String userType, required String title}) {
  try {
    String normTitle = _normalizeText(title);
    if (userType == 'student') {
      final prov = Get.put(student_list.ChatTeacherListProvider());
      final list = prov.student;
      if (list.isNotEmpty) {
        final match = list.firstWhereOrNull((e) {
          final name = (e['account_name'] ?? '').toString();
          final normName = _normalizeText(name);
          return normName == normTitle ||
              normName.contains(normTitle) ||
              normTitle.contains(normName);
        });
        if (match != null) {
          Get.offAll(() => student_chat.ChatPage(
                userInfo: Map.from(match),
                contentUrl: prov.contentUrl,
                isChatOpen: true,
              ));
          return true;
        }
      }
    } else if (userType == 'teacher') {
      final prov = Get.put(teacher_list.ChatStudentListProvider());
      final list = prov.student;
      if (list.isNotEmpty) {
        final match = list.firstWhereOrNull((e) {
          final name = (e['account_name'] ?? '').toString();
          final normName = _normalizeText(name);
          return normName == normTitle ||
              normName.contains(normTitle) ||
              normTitle.contains(normName);
        });
        if (match != null) {
          Get.offAll(() => teacher_chat.ChatPage(
                userInfo: Map.from(match),
                contentUrl: prov.contentUrl,
              ));
          return true;
        }
      }
    }
  } catch (e) {
    Logger().w('openChatByTitleIfPossible error: $e');
  }
  return false;
}

Future<bool> _tryLoadAndOpenByTitle({required String userType, required String title}) async {
  try {
    if (userType == 'student') {
      final prov = Get.put(student_list.ChatTeacherListProvider());
      if (prov.student.isEmpty) {
        final main = Get.put(MainDataGetProvider());
        final String classesId =
            main.mainData['account']['account_division_current']['_id'];
        final String studyYear = main.mainData['setting'][0]['setting_year'];
        prov.getStudent(0, classesId, studyYear, '');
        await Future.delayed(const Duration(milliseconds: 400));
      }
      return _openChatByTitleIfPossible(userType: 'student', title: title);
    } else if (userType == 'teacher') {
      final prov = Get.put(teacher_list.ChatStudentListProvider());
      if (prov.student.isEmpty) {
        final main = Get.put(MainDataGetProvider());
        final List classes = main.mainData['account']['account_division'] ?? [];
        final List classesIds =
            classes.map((e) => e['_id'].toString()).toList(growable: false);
        final String studyYear = main.mainData['setting'][0]['setting_year'];
        prov.getStudent(0, classesIds, studyYear, '');
        await Future.delayed(const Duration(milliseconds: 400));
      }
      return _openChatByTitleIfPossible(userType: 'teacher', title: title);
    }
  } catch (e) {
    Logger().w('_tryLoadAndOpenByTitle error: $e');
  }
  return false;
}

String _normalizeText(String input) {
  // Trim, collapse spaces, and lowercase; good-enough normalization for Arabic/English names
  final collapsed = input.replaceAll(RegExp(r"\s+"), ' ').trim();
  return collapsed.toLowerCase();
}
