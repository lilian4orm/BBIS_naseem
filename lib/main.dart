import 'package:BBInaseem/provider/locale_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:upgrader/upgrader.dart';
import 'init_data.dart';
import 'provider/auth_provider.dart';
import 'screens/auth/login_page.dart';
import 'screens/driver/driver_home.dart';
import 'screens/student/student_home.dart';
import 'screens/teacher/teacher_home.dart';
import 'static_files/my_color.dart';
import 'static_files/my_translations.dart';
import 'static_files/my_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

//parse
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

late SharedPreferences sharePref;

void main() async {
  final box = GetStorage();
  Map? userData = box.read('_userData');
  Get.put(TokenProvider()).addToken(userData);
  Get.put(MainDataGetProvider());
  WidgetsFlutterBinding.ensureInitialized();
  sharePref = await SharedPreferences.getInstance();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );

  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = MyColor.purple
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.yellow.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MylocaleController localController = Get.put(MylocaleController());
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: TranslationsItems(),
        defaultTransition: Transition.fade,
        fallbackLocale: const Locale("en"),
        locale: localController.getInitLocale(),
        theme: ThemeData(
          fontFamily: 'Almarai',
          scaffoldBackgroundColor: MyColor.white0,
          primarySwatch: MyColor().purpleMaterial,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            error: Colors.red,
          ),
          tabBarTheme: const TabBarThemeData(
            labelStyle: TextStyle(fontFamily: 'Almarai'),
            unselectedLabelStyle: TextStyle(fontFamily: 'Almarai'),
          ),
        ),
        builder: EasyLoading.init(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ),
        home: Builder(builder: (context) {
          return UpgradeAlert(
            upgrader: Upgrader(
              durationUntilAlertAgain: const Duration(seconds: 10),
              languageCode: 'en',
            ),
            child:
                //const SplashScreenWellcome(),
                _redirectToPage(),
          );
        }));
  }
}

Widget _redirectToPage() {
  final box = GetStorage();
  Map? userData = box.read('_userData');

  socketURL = socketURLSchool;
  Get.put(TokenProvider()).addToken(userData);

  if (userData == null) {
    return const LoginPage();
  } else if (userData["account_type"] == "student") {
    Get.put(TokenProvider()).addToken(userData);
    return HomePageStudent(userData: userData);
  } else if (userData["account_type"] == "driver") {
    Get.put(TokenProvider()).addToken(userData);
    return HomePageDriver(userData: userData);
  } else if (userData["account_type"] == "teacher") {
    Get.put(TokenProvider()).addToken(userData);
    return HomePageTeacher(userData: userData);
  } else {
    return const LoginPage();
  }
}
