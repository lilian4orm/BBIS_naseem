import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:BBInaseem/provider/accounts_provider.dart';
import '../../../api_connection/student/api_profile.dart';
import '../../../local_database/sql_database.dart';
import '../../../static_files/my_times.dart';

class EditProfile extends StatefulWidget {
  final Map userData;

  const EditProfile({super.key, required this.userData});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final AccountProvider accountProvider = Get.put(AccountProvider());
  final StudentProfileAPI studentProfileAPI = Get.put(StudentProfileAPI());
  final _formKey = GlobalKey<FormState>();

  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mobileController.text = widget.userData['account_mobile'] ?? '';
    addressController.text = widget.userData['account_address'] ?? '';
    final birthday = widget.userData['account_birthday'] ?? '';
    birthdayController.text =
        birthday.isNotEmpty ? fromISOToDate(birthday.toString()) : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('editPF'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _editTextField('birth'.tr, birthdayController,
                  enableDatePicker: true),
              _editTextField('phone'.tr, mobileController,
                  enableDatePicker: false, validator: _phoneValidator),
              _editTextField("Address".tr, addressController,
                  enableDatePicker: false),
              ElevatedButton(
                onPressed: () => _updateProfile(),
                child: Text('updateFile'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _phoneValidator(String? phoneNumber) {
    if (phoneNumber != null && phoneNumber.length == 11) {
      return null;
    } else {
      return 'pho11chk'.tr;
    }
  }

  Widget _editTextField(String label, TextEditingController controller,
      {required bool enableDatePicker, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextFormField(
        readOnly: enableDatePicker,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: enableDatePicker
              ? IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (selectedDate != null) {
                      controller.text =
                          selectedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                )
              : null,
        ),
        onTap: enableDatePicker
            ? () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                );

                if (selectedDate != null) {
                  controller.text =
                      selectedDate.toLocal().toString().split(' ')[0];
                }
              }
            : null,
        validator: validator,
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = await studentProfileAPI.editBirthdayAddressMobile(
          mobileController.text,
          DateTime.parse(birthdayController.text).toIso8601String(),
          addressController.text,
        );

        await updateLocalDatabase(data['results']);

        Get.snackbar("success".tr, 'upDone'.tr);
      } catch (e) {
        Get.snackbar("failed".tr, 'updF'.tr);
      }
    }
  }

  Future<void> updateLocalDatabase(Map<String, dynamic> data) async {
    Logger().d(data);
    final box = GetStorage();
    Map? userData = box.read('_userData');
    data.forEach((key, value) {
      userData?[key] = value;
    });
    await box.write('_userData', userData);
    final SqlDatabase sqlDatabase = SqlDatabase();
    await sqlDatabase.updateUser(widget.userData['account_email'], data);
    accountProvider.fetchAccounts();
  }
}
