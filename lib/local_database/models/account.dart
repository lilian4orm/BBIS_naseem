class Account {
  String? token;
  String? id;
  String? accountName;
  String? accountMobile;
  String? accountType;
  String? accountEmail;
  DateTime? accountBirthday;
  String? accountAddress;

  Account({
    required this.token,
    required this.id,
    required this.accountName,
    required this.accountMobile,
    required this.accountType,
    required this.accountEmail,
    required this.accountBirthday,
    required this.accountAddress,
  });

  factory Account.fromMap(Map<String, dynamic> json) {
    print('json');
    print(json);
    return Account(
      token: json['token'] ?? '',
      id: json['_id'] ?? '',
      accountName: json['account_name'] ?? '',
      accountMobile: json['account_mobile'] ?? '',
      accountType: json['account_type'] ?? '',
      accountEmail: json['account_email'] ?? '',
      accountBirthday: json['account_birthday'] != null
          ? DateTime.parse(json['account_birthday'])
          : null,
      accountAddress: json['account_address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      '_id': id,
      'account_name': accountName,
      'account_mobile': accountMobile,
      'account_type': accountType,
      'account_email': accountEmail,
      'account_birthday': accountBirthday?.toIso8601String(),
      'account_address': accountAddress,
    };
  }
}