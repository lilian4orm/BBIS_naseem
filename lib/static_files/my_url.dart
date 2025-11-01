//const String mainApi = "https://api.lm-uat.com/api/mobile/";
//const String socketURL = "https://api.lm-uat.com/";

import 'package:BBInaseem/provider/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

const String socketURLSchool = "https://api.lm-uat.com/";

const String schoolURL = "https://api.lm-uat.com/api/mobile/";

String mainApi = schoolURL;
String socketURL = socketURLSchool;

followTopics() async {
  String id =
      Get.put(MainDataGetProvider()).mainData['account']['school']['_id'];
  String type = Get.put(MainDataGetProvider()).type;
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic('school_$id');
    if (type == 'student') {
      await messaging.subscribeToTopic('all_students_$id');
      await messaging.unsubscribeFromTopic('all_teachers_$id');
      await messaging.unsubscribeFromTopic('all_drivers_$id');
    } else if (type == 'teacher') {
      await messaging.subscribeToTopic('all_teachers_$id');
      await messaging.unsubscribeFromTopic('all_students_$id');
      await messaging.unsubscribeFromTopic('all_drivers_$id');
    } else if (type == 'driver') {
      await messaging.subscribeToTopic('all_drivers_$id');
      await messaging.unsubscribeFromTopic('all_students_$id');
      await messaging.unsubscribeFromTopic('all_teachers_$id');
    }
  } catch (e) {}
}
