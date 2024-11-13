import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:BBInaseem/local_database/models/account.dart';
import 'package:BBInaseem/local_database/sql_database.dart';
import '../api_connection/auth_connection.dart';

class AccountProvider extends GetxController {
  RxList<Account> accounts = <Account>[].obs;

  @override
  void onInit() {
    fetchAccounts(); // You don't need to set accounts.value = [] here.
    super.onInit();
  }

  Future<void> fetchAccounts() async {
    try {
      final updatedAccounts = await SqlDatabase.db.getAllAccount();
      accounts.assignAll(updatedAccounts);
    } catch (e) {
      print('Error fetching accounts: $e');
    }
  }

  Future<void> deleteAccount(Account account) async {
    try {
      await SqlDatabase.db.deleteAccount(account.accountEmail!);
      await Auth().loginOut(account.token);
      await fetchAccounts();
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  Future<void> onClickAccount(res) async {
    final box = GetStorage();
    box.erase();
    await box.write('_userData', res);
    await fetchAccounts();
  }

  @override
  void onClose() {
    // Close any resources here (e.g., close database connections).
    super.onClose();
  }
}
