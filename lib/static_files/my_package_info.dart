import 'package:package_info_plus/package_info_plus.dart';
Future<String> packageInfo() async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;
  return Future.value("$buildNumber+$version");
}