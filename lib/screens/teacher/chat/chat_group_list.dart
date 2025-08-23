import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:line_icons/line_icons.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../../../api_connection/teacher/api_other.dart';
import '../../../api_connection/teacher/chat/api_chat_group_list.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/teacher/chat/chat_all_list_items.dart';
import '../../../provider/teacher/chat/chat_message.dart';
import '../../../provider/teacher/chat/image_provider.dart';
import '../../../static_files/my_color.dart';
import '../../../static_files/my_loading.dart';
import '../../../static_files/my_random.dart';
import '../../../static_files/my_times.dart';
import 'chat_main/chat_page_group.dart';

class ChatGroupList extends StatefulWidget {
  const ChatGroupList({Key? key}) : super(key: key);

  @override
  State<ChatGroupList> createState() => _ChatGroupListState();
}

class _ChatGroupListState extends State<ChatGroupList> {
  TextEditingController groupName = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  // final MainDataGetProvider _mainDataGetProvider = Get.put(MainDataGetProvider());
  final ScrollController _scrollController = ScrollController();
  // final List _classes = Get.put(MainDataGetProvider()).mainData['account']['account_division'];
  final MainDataGetProvider _mainDataProvider = Get.put(MainDataGetProvider());
  List<String> _student = [];
  List<S2Choice<String>> student = [];
  _showStudent({required List<String> initialUsers}) {
    Logger().i(initialUsers);
    List accountDivision = [];
    for (Map division in _mainDataProvider.mainData['account']
        ['account_division']) {
      accountDivision.add(division['_id']);
    }
    Map data = {
      "study_year": _mainDataProvider.mainData['setting'][0]['setting_year'],
      "class_school": accountDivision
    };
    OtherApi().getStudent(data, false).then((res) {
      student.clear();
      _student.clear();
      for (Map _data in res) {
        student.add(
          S2Choice<String>(
              value: _data['_id'],
              title: _data['account_name'],
              group:
                  "${_data['account_division_current']['class_name']} - ${_data['account_division_current']['leader']}",
              selected: initialUsers.contains(_data['_id'])),
        );
      }
    });
  }

  int page = 0;
  _getStudentList() {
    if (page != 0) {
      EasyLoading.show(status: 'getData'.tr);
    }
    ChatGroupListAPI().getGroupList().then((res) {
      EasyLoading.dismiss();
      if (!res['error']) {
        if (page == 0) {
          Get.put(ChatGroupListProvider()).clear();
          Get.put(ChatGroupListProvider()).changeContentUrl(res["content_url"]);
          Get.put(ChatGroupListProvider()).changeLoading(false);
        }
        Get.put(ChatGroupListProvider()).addStudent(res["results"]);
      } else {
        EasyLoading.showError(res['message'].toString());
      }
    });
  }

  @override
  void initState() {
    _getStudentList();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    //     page++;
    //     _getStudentList();
    //   }
    // });
    _showStudent(initialUsers: []);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<ChatGroupListProvider>(builder: (val) {
          return val.student.isEmpty && val.isLoading
              ? Center(
                  child: loadingChat(),
                )
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      _groups(val.student[index], val.contentUrl),
                    ],
                  ),
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: val.student.length,
                );
        }),
        Positioned(
          bottom: 16.0,
          left: 16.0,
          child: FloatingActionButton(
            onPressed: _showCreateGroupBottomSheet,
            backgroundColor: MyColor.purple,
            tooltip: 'createGroup'.tr,
            child: const Icon(Icons.supervisor_account),
          ),
        ),
      ],
    );
  }

  _groups(Map data, String contentUrl) {
    return ListTile(
      title: Text(
        data['group_name'].toString(),
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: data['chats']['data'].length == 0
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                    decoration: data['chats']['data'][0]
                            ['group_message_is_deleted']
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1.0,
                              color: Colors.grey.shade300,
                            ),
                          )
                        : null,
                    child: Text(
                        data['chats']['data'][0]['group_message_is_deleted']
                            ? 'msgDeleted'.tr
                            : data['chats']['data'][0]['group_message'] ??
                                'fileSended'.tr,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: data['chats']['data'][0]['isRead']
                                ? FontWeight.normal
                                : FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
      leading: profileImg(contentUrl, data['group_img']),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (data['chats']['data'].isNotEmpty)
            _timeText(data['chats']['data'][0]['created_at']),
          if (data['chats']['countUnRead'] > 0)
            _messageUnRead(data['chats']['countUnRead']),
        ],
      ),
      onTap: () async {
        Get.put(ChatMessageGroupProvider()).clear();
        Get.put(ChatMessageGroupProvider()).addListChat(data['chats']['data']);
        Get.put(ChatGroupListProvider()).changeReadingCount(data["_id"]);
        await Get.to(
            () => ChatPageGroup(userInfo: data, contentUrl: contentUrl));
        page = 0;
        _getStudentList();
      },
      onLongPress: () =>
          _deleteGroup(data['_id'], data['group_name'], data['group_users']),
    );
  }

  Widget profileImg(String contentUrl, String? img) {
    if (img == null) {
      return const CircleAvatar(
        backgroundImage: AssetImage("assets/img/ايكونه تطبيق2 (2).png"),
      );
    } else {
      return CircleAvatar(
        //radius: 30,
        backgroundImage: CachedNetworkImageProvider(
          contentUrl + img,
          // fit: BoxFit.cover,
          // placeholder: (context, url) => Row(
          //   mainAxisSize: MainAxisSize.min,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: const [
          //     CircularProgressIndicator(),
          //   ],
          // ),
          // errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        //backgroundColor: Colors.red,
        // child: CachedNetworkImage(
        //   imageUrl: _contentUrl + _img,
        //   fit: BoxFit.cover,
        //   placeholder: (context, url) => Row(
        //     mainAxisSize: MainAxisSize.min,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: const [
        //       CircularProgressIndicator(),
        //     ],
        //   ),
        //   errorWidget: (context, url, error) => const Icon(Icons.error),
        // ),
      );
    }
  }

  Text _timeText(int time) {
    return Text(
      getChatDate(time, 12),
      style: const TextStyle(fontSize: 10),
    );
  }

  Widget _messageUnRead(int count) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: MyColor.green,
      ),
      padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
      child: count > 99
          ? const Text(
              "99+",
              style: TextStyle(fontSize: 10, color: MyColor.white0),
            )
          : Text(
              count.toString(),
              style: const TextStyle(fontSize: 10, color: MyColor.white0),
            ),
    );
  }

  _showCreateGroupBottomSheet() {
    _student.clear();
    Get.bottomSheet(Container(
      decoration: const BoxDecoration(
          color: MyColor.white0,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('createGroup'.tr),
            trailing: InkWell(
              child: const Icon(Icons.close),
              onTap: () {
                Get.back();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: groupName,
              style: const TextStyle(
                color: MyColor.black,
              ),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  hintText: 'description'.tr,
                  errorStyle: const TextStyle(color: MyColor.grayDark),
                  fillColor: Colors.transparent,
                  filled: true
                  //fillColor: Colors.green
                  ),
              validator: (value) {
                var result = value!.length < 3 ? 'fillAllField'.tr : null;
                return result;
              },
            ),
            leading: groupImage(),
          ),
          Container(
            margin:
                const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: MyColor.purple,
              ),
              color: MyColor.white0,
            ),
            child: SmartSelect<String>.multiple(
                title: "students".tr,
                placeholder: 'pick'.tr,
                selectedValue: _student,
                choiceGrouped: true,
                onChange: (selected) {
                  setState(() => _student = selected.value);
                  //_showData(selected.value);
                },
                groupHeaderStyle:
                    const S2GroupHeaderStyle(backgroundColor: MyColor.white4),
                choiceItems: student,
                modalFilter: true,
                modalFilterAuto: true),
          ),
          const Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: Get.width / 1.2,
                child: RoundedLoadingButton(
                  color: MyColor.purple,
                  valueColor: MyColor.white0,
                  successColor: MyColor.purple,
                  controller: _btnController,
                  onPressed: _createGroup,
                  borderRadius: 10,
                  child: Text('addGroup'.tr,
                      style: const TextStyle(
                          color: MyColor.white0,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget groupImage() {
    return GetBuilder<ImageGroupProvider>(builder: (val) {
      return GestureDetector(
          onTap: pickImage,
          child: val.pic == null
              ? const CircleAvatar(
                  backgroundImage: AssetImage("assets/img/photo.png"),
                )
              : CircleAvatar(
                  //radius: 30,
                  backgroundImage: FileImage(val.pic!),
                  //backgroundColor: Colors.red,
                  // child: CachedNetworkImage(
                  //   imageUrl: _contentUrl + _img,
                  //   fit: BoxFit.cover,
                  //   placeholder: (context, url) => Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: const [
                  //       CircularProgressIndicator(),
                  //     ],
                  //   ),
                  //   errorWidget: (context, url, error) => const Icon(Icons.error),
                  // ),
                ));
    });
  }

  Future<XFile?> compressAndGetFile(File file, String targetPath) async {
    String getRand = RandomGen().getRandomString(5);
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, "$targetPath/img_$getRand.jpg",
        quality: 40);
    return result;
  }

  pickImage() async {
    EasyLoading.show(status: "loading".tr);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      compressAndGetFile(file, p.dirname(file.path)).then((value) {
        Get.put(ImageGroupProvider()).changeImage(file);
        EasyLoading.dismiss();
      });
    } else {
      EasyLoading.dismiss();
    }
  }

  _createGroup() {
    File? pic = Get.put(ImageGroupProvider()).pic;
    dio.FormData data = dio.FormData.fromMap({
      "group_name": groupName.text,
      "group_users": _student,
      "group_img": pic == null
          ? null
          : dio.MultipartFile.fromFileSync(pic.path,
              filename: 'img.jpg', contentType: MediaType('image', 'jpg')),
    });
    if (groupName.text.trim().isNotEmpty) {
      ChatGroupListAPI().createGroup(data).then((res) {
        if (res['error']) {
          _btnController.error();
          Timer(const Duration(seconds: 2), () {
            _btnController.reset();
          });
        } else {
          _btnController.success();
          _getStudentList();
          Timer(const Duration(seconds: 2), () {
            Get.back();
            pic = null;
          });
        }
      });
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 2), () {
        _btnController.reset();
      });
    }
  }

  _deleteGroup(String id, groupName, List users) {
    Get.bottomSheet(
      Container(
        color: MyColor.white0,
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  //delete
                  EasyLoading.show(status: "deleting".tr);
                  ChatGroupListAPI().deleteGroup(id).then((res) {
                    if (res != null) {
                      page = 0;
                      _getStudentList();
                      Timer(const Duration(milliseconds: 200), () {
                        Get.close(1);
                      });
                    }
                    EasyLoading.dismiss();
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LineIcons.alternateTrashAlt),
                    Text("delete".tr)
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showEditGroupBottomSheet(groupName,
                      users.map((e) => e['_id'].toString()).toList(), id);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LineIcons.edit),
                    Text("edit".tr),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showEditGroupBottomSheet(
      String name, List<String> users, String groupId) async {
    await _showStudent(initialUsers: users);
    Get.bottomSheet(Container(
      decoration: const BoxDecoration(
          color: MyColor.white0,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('editGroup'.tr),
            trailing: InkWell(
              child: const Icon(Icons.close),
              onTap: () {
                Get.back();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: TextFormField(
              controller: groupName..text = name,
              style: const TextStyle(
                color: MyColor.black,
              ),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  hintText: 'description'.tr,
                  errorStyle: const TextStyle(color: MyColor.grayDark),
                  fillColor: Colors.transparent,
                  filled: true
                  //fillColor: Colors.green
                  ),
              validator: (value) {
                var result = value!.length < 3 ? 'fillAllField'.tr : null;
                return result;
              },
            ),
            leading: groupImage(),
          ),
          Container(
              margin: const EdgeInsets.only(
                  top: 10, bottom: 10, right: 10, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: MyColor.purple,
                ),
                color: MyColor.white0,
              ),
              child: SmartSelect<String>.multiple(
                title: "students".tr,
                placeholder: 'pick'.tr,
                choiceGrouped: true,
                onChange: (selected) {
                  setState(() => _student = selected.value);
                },
                groupHeaderStyle:
                    const S2GroupHeaderStyle(backgroundColor: MyColor.white4),
                selectedValue: users,
                modalFilter: true,
                choiceItems: student,
                modalFilterAuto: true,
              )),
          const Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: Get.width / 1.2,
                child: RoundedLoadingButton(
                  color: MyColor.purple,
                  valueColor: MyColor.white0,
                  successColor: MyColor.purple,
                  controller: _btnController,
                  onPressed: () => _editGroup(groupId),
                  borderRadius: 10,
                  child: Text('editGroup'.tr,
                      style: const TextStyle(
                          color: MyColor.white0,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  _editGroup(String groupId) {
    File? pic = Get.put(ImageGroupProvider()).pic;
    dio.FormData data = dio.FormData.fromMap({
      "group_name": groupName.text,
      "group_users": _student,
      "group_img": pic == null
          ? null
          : dio.MultipartFile.fromFileSync(pic.path,
              filename: 'img.jpg', contentType: MediaType('image', 'jpg')),
      "_id": groupId
    });
    if (groupName.text.trim().isNotEmpty) {
      ChatGroupListAPI().editGroup(data).then((res) {
        if (res['error']) {
          _btnController.error();
          Timer(const Duration(seconds: 2), () {
            _btnController.reset();
          });
        } else {
          _btnController.success();
          _getStudentList();
          Timer(const Duration(milliseconds: 200), () {
            Get.close(2);
            pic = null;
          });
        }
        groupName.clear();
        Get.put(ImageGroupProvider()).pic = null;
      });
    } else {
      _btnController.error();
      Timer(const Duration(seconds: 2), () {
        _btnController.reset();
      });
    }
  }
}
