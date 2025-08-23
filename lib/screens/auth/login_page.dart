import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:BBInaseem/main.dart';
import 'package:BBInaseem/provider/locale_controller.dart';
import 'package:BBInaseem/screens/auth/accounts_screen.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_id/flutter_device_id.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../api_connection/auth_connection.dart';
import '../../provider/auth_provider.dart';
import '../../static_files/my_color.dart';
import '../driver/driver_home.dart';
import '../student/student_home.dart';
import '../teacher/teacher_home.dart';
// import 'connectUs.dart';
// import 'requestCer.dart';
// import 'requestJop.dart';

import 'connect_us.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  TokenProvider get tokenProvider => Get.put(TokenProvider());
  final box = GetStorage();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  MylocaleController localController = Get.put(MylocaleController());

  final _formCheck = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  Map? authData;
  shaConvert(pass) {
    var bytes = utf8.encode(pass);
    Digest sha512Result = sha512.convert(bytes);
    return sha512Result.toString();
  }

  _login() async {
    final box = GetStorage();
    Map data = {
      "account_email": email.text,
      "account_password": shaConvert(pass.text),
      "auth_ip": authData?['query']?.toString() ?? '', // Add null check
      "auth_city": (authData?['country']?.toString() ?? '') +
          (authData?['city']?.toString() ?? ''), // Add null check
      "auth_lon": authData?['lon']?.toString() ?? '', // Add null check
      "auth_lat": authData?['lat']?.toString() ?? '', // Add null check
      "auth_phone_details": await getDeviceInfo(),
      "auth_phone_id": await getPhoneId(),
      "auth_firebase": await FirebaseMessaging.instance.getToken()
    };

    if (_formCheck.currentState!.validate() && authData != null) {
      Auth().login(data).then((res) async {
        if (res != null && res['error'] != null) {
          if (!res['error']) {
            _btnController.success();
            await box.write('_userData', res['results']);
            tokenProvider.addToken(res['results']);

            String accountType = res['results']?["account_type"] ?? '';

            if (accountType == "student") {
              Get.put(MainDataGetProvider()).changeType('student');

              tokenProvider.addAccountToDatabase(res['results']);
              Timer(const Duration(seconds: 1), () {
                Get.offAll(() => HomePageStudent(userData: res['results']));
              });
            } else if (accountType == "driver") {
              Get.put(MainDataGetProvider()).changeType('driver');
              tokenProvider.addAccountToDatabase(res['results']);
              Timer(const Duration(seconds: 1), () {
                Get.to(() => HomePageDriver(userData: res['results']));
              });
            } else if (accountType == "teacher") {
              Get.put(MainDataGetProvider()).changeType('teacher');
              tokenProvider.addAccountToDatabase(res['results']);
              Timer(const Duration(seconds: 1), () {
                Get.offAll(() => HomePageTeacher(userData: res['results']));
              });
            } else {
              _btnController.error();
              EasyLoading.showError(res['message']?.toString() ?? '');
              Timer(const Duration(seconds: 2), () {
                _btnController.reset();
              });
            }
          } else {
            _btnController.error();
            EasyLoading.showError(res['message']?.toString() ?? '');
            Timer(const Duration(seconds: 2), () {
              _btnController.reset();
            });
          }
        } else {
          EasyLoading.showError('errVar'.tr);
        }
      });
    } else if (authData == null) {
      getIp();
      EasyLoading.showError('errVar'.tr);
      _btnController.reset();
    } else {
      _btnController.reset();
    }
  }

  ///teacher@g.com
  getDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return "${androidInfo.manufacturer}, ${androidInfo.brand}, ${androidInfo.model}, ${androidInfo.board}";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return "${iosDeviceInfo.utsname.machine}, ${iosDeviceInfo.utsname.sysname}, ${iosDeviceInfo.model}";
    } else {
      return "NoData";
    }
  }

  Future<String?> getPhoneId() async {
    final flutterDeviceIdPlugin = FlutterDeviceId();

    String? deviceId = await flutterDeviceIdPlugin.getDeviceId() ?? '';
    return deviceId;
  }

  getIp() {
    Auth().getIp().then((res) {
      if (res['status'] == "success") {
        authData = res;
      }
    });
  }

  @override
  void initState() {
    getIp();
    super.initState();
  }

  bool _obscurePassword = true;
  changeObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = Get.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        top: false,
        child: SizedBox(
          height: Get.height,
          child: SingleChildScrollView(
            child: SizedBox(
              height: Get.height,
              child: Column(
                children: [
                  SizedBox(
                    height: Get.height * .05,
                  ),
                  Expanded(
                      child: Stack(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Image.asset("assets/img/logo.png")),
                      // Positioned(
                      //   top: 10,
                      //   right: 10,
                      //   child: IconButton.filled(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.grey.withOpacity(0.5),
                      //       shadowColor: Colors.transparent,
                      //     ),
                      //     onPressed: () {
                      //       if (box.read('language') == 'en') {
                      //         localController.changeLanguage('ar');
                      //       } else {
                      //         localController.changeLanguage('en');
                      //       }
                      //     },
                      //     icon: const Icon(Icons.language),
                      //     color: MyColor.purple,
                      //   ),
                      // )
                    ],
                  )),
                  Form(
                    key: _formCheck,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 20, right: 20, left: 20),
                          child: TextFormField(
                            controller: email,
                            style: const TextStyle(
                              color: MyColor.black,
                            ),
                            decoration: InputDecoration(
                                labelText: 'email'.tr,
                                prefixIcon: const Icon(Icons.email),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24),
                                errorStyle:
                                    const TextStyle(color: MyColor.grayDark),
                                fillColor: const Color(0xFFFAFAFA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                filled: true),
                            validator: (value) {
                              var result = value!.length < 3
                                  ? "please fill all field".tr
                                  : null;
                              return result;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, right: 20, left: 20),
                          child: TextFormField(
                            controller: pass,
                            style: const TextStyle(
                              color: MyColor.black,
                            ),
                            decoration: InputDecoration(
                                labelText: "Password".tr,
                                prefixIcon: const Icon(Icons.key),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 24),
                                errorStyle:
                                    const TextStyle(color: MyColor.grayDark),
                                fillColor: const Color(0xFFFAFAFA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                suffixIcon: _obscurePassword
                                    ? IconButton(
                                        onPressed: changeObscurePassword,
                                        icon: const Icon(LineIcons.eyeSlash))
                                    : IconButton(
                                        onPressed: changeObscurePassword,
                                        icon: const Icon(LineIcons.eye)),
                                filled: true
                                //fillColor: Colors.green
                                ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              var result = value!.length < 4
                                  ? "please fill all field".tr
                                  : null;
                              return result;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: width * .4,
                      child: RoundedLoadingButton(
                        height: 56,
                        color: MyColor.purple,
                        valueColor: MyColor.white0,
                        successColor: MyColor.purple,
                        controller: _btnController,
                        onPressed: _login,
                        borderRadius: 10,
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('Login button'.tr,
                              style: const TextStyle(
                                  color: MyColor.white0,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buttons('callus'.tr, width, const ConnectUs()),
                      guestLogin('guestLogin'.tr, width),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buttons('acounts'.tr, width, const AccountsScreen()),
                      // _buttons('joinus'.tr, width, const JoinUs()),
                    ],
                  ),
                  SizedBox(height: Get.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buttons(t, width, Widget nav) {
    return SizedBox(
      width: width / 2.5,
      child: MaterialButton(
          color: MyColor.yellow,
          elevation: 0,
          onPressed: () {
            Get.to(() => nav);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: AutoSizeText(
            t,
            maxFontSize: 14,
            minFontSize: 11,
            maxLines: 1,
            style: const TextStyle(color: MyColor.purple),
          )),
    );
  }

  guestLogin(t, width) {
    return SizedBox(
      width: width / 2.5,
      child: MaterialButton(
          color: MyColor.yellow,
          elevation: 0,
          onPressed: () {
            sharePref.setString('guest', 'guest');
            Get.to(() => const HomePageStudent(userData: {}));
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: AutoSizeText(
            t,
            maxFontSize: 14,
            minFontSize: 11,
            maxLines: 1,
            style: const TextStyle(color: MyColor.purple),
          )),
    );
  }

  _title(String icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              title,
              style: const TextStyle(
                  color: MyColor.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // txtFormField(TextEditingController _controller, String _hint) {
  //   return Container(
  //     constraints: const BoxConstraints(maxWidth: 350),
  //     padding: const EdgeInsets.only(top: 15),
  //     // child: TextFormField(
  //     //   maxLines: 1,
  //     //   controller: _controller,
  //     //   cursorRadius: Radius.circular(16.0),
  //     //   //cursorWidth: 2.0,
  //     //   // inputFormatters: <TextInputFormatter>[
  //     //   //   FilteringTextInputFormatter.digitsOnly,
  //     //   // ],
  //     //   style: TextStyle(fontSize: 16),
  //     //   obscureText: _hint == "الرقم السري" ? true : false,
  //     //   autofocus: false,
  //     //   decoration: InputDecoration(
  //     //       labelText: _hint,
  //     //       contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
  //     //       fillColor: MyColor.c3,
  //     //       border: OutlineInputBorder(
  //     //         borderRadius: BorderRadius.circular(15.0),
  //     //         borderSide: BorderSide(
  //     //           color: MyColor.c3,
  //     //         ),
  //     //       ),
  //     //       enabledBorder: OutlineInputBorder(
  //     //         borderRadius: BorderRadius.circular(15.0),
  //     //         borderSide: BorderSide(
  //     //           color: MyColor.c3,
  //     //         ),
  //     //       ),
  //     //       focusedBorder: OutlineInputBorder(
  //     //         borderRadius: BorderRadius.circular(15.0),
  //     //         borderSide: BorderSide(
  //     //           color: MyColor.c3,
  //     //         ),
  //     //       ),
  //     //       errorBorder: OutlineInputBorder(
  //     //         borderRadius: BorderRadius.circular(15.0),
  //     //         borderSide: BorderSide(
  //     //           color: MyColor.c5,
  //     //         ),
  //     //       ),
  //     //       prefixIcon: _hint == "الرقم السري" ? Icon(LineIcons.lock) : Icon(LineIcons.user),
  //     //       filled: true
  //     //     //fillColor: Colors.green
  //     //   ),
  //     // ),
  //   );
  // }

  // ignore: non_constant_identifier_names
  // void _LoginCheck() async {
  //   Map _data = {
  //     "username": user.text,
  //     "password": pass.text
  //   };
  //   Auth().login(_data).then((response) {
  //     if(response['error']==false) {
  //       if(_saveData){
  //         final box = GetStorage();
  //         box.write('_token', response['accessToken']);
  //         box.write('_userData', response['results']);
  //       }
  //       _btnController.success();
  //       Timer(Duration(seconds: 1), () {
  //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
  //           return Dashboard(token: response['accessToken'],userData: response['results']);
  //         }));
  //       });
  //     }else{
  //       _btnController.error();
  //       Timer(Duration(seconds: 2), () {
  //         _btnController.reset();
  //       });
  //     }
  //   });
  //   _btnController.reset();
  //   // Timer(Duration(seconds: 3), () {
  //   //   _btnController.success();
  //   // });
  // }
}
