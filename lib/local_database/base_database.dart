import 'package:BBInaseem/local_database/models/account.dart';

abstract class BaseDatabase{

  Future insertAccount(Account account);
  Future insertAccountAsMap(Map<String,dynamic> account);
  Future deleteAccount(String email);
  Future<Account?> getAccount(String email);
  Future<List<Account>> getAllAccount();
  close();
}