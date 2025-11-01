import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../api_connection/auth_connection.dart';

class DialogHelpers {
  static Future<void> showVersionDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('appVersion'.tr),
          content: Text('${'version'.tr}: ${packageInfo.version}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ok'.tr),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showLogoutDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr),
          content: Text('logoutConfirmation'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Auth().loginOut();
              },
              child: Text('logout'.tr),
            ),
          ],
        );
      },
    );
  }
}
