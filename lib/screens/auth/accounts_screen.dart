import 'package:BBInaseem/provider/accounts_provider.dart';
import 'package:BBInaseem/provider/auth_provider.dart';
import 'package:BBInaseem/screens/auth/login_page.dart';
import 'package:BBInaseem/static_files/my_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AccountProvider accountProvider = Get.put(AccountProvider());

  TokenProvider get tokenProvider => Get.put(TokenProvider());

  onCLickAccount(Map<String, dynamic> account) async {
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
  void initState() {
    accountProvider.fetchAccounts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyColor.yellow,
            title: Text(
              'acounts'.tr,
              style: const TextStyle(color: MyColor.purple),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: MyColor.purple,
            ),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const LoginPage());
                  },
                  child: const Icon(
                    Icons.add,
                  ),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              Obx(() => ListView.builder(
                  shrinkWrap: true,
                  itemCount: accountProvider.accounts.length,
                  padding: const EdgeInsets.all(24),
                  itemBuilder: (context, index) {
                    final account = accountProvider.accounts[index];
                    return GestureDetector(
                        onTap: () {
                          if (tokenProvider.userData?['account_email'] !=
                              account.accountEmail) {
                            onCLickAccount(
                                accountProvider.accounts[index].toMap());
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/img/logo.png"),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(account.accountName!),
                                  Text(account.accountEmail!)
                                ],
                              )),
                              const SizedBox(
                                width: 16,
                              ),
                              if (tokenProvider.userData?['account_email'] !=
                                  account.accountEmail)
                                GestureDetector(
                                  onTap: () =>
                                      accountProvider.deleteAccount(account),
                                  child: const Icon(Icons.delete),
                                )
                            ],
                          ),
                        ));
                  }))
            ],
          )),
    );
  }
}
