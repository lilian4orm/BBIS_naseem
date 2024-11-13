import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:BBInaseem/static_files/common_function.dart';
import '../../../../../api_connection/student/chat/api_add_files_chat.dart';
import '../../../../../api_connection/student/chat/api_chat_group_list.dart';
import '../../../../../provider/auth_provider.dart';
import '../../../../../provider/student/chat/chat_all_list_items.dart';
import '../../../../../provider/student/chat/chat_message.dart';
import '../../../../../provider/student/chat/chat_socket.dart';
import '../../../../../static_files/my_group_static_files_student.dart';
import '../../../../../static_files/my_color.dart';
import '../../../../../static_files/my_times.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

class ChatPageGroup extends StatefulWidget {
  final Map userInfo;
  final String contentUrl;
  final bool isChatOpen;
  const ChatPageGroup(
      {Key? key,
      required this.userInfo,
      required this.contentUrl,
      required this.isChatOpen})
      : super(key: key);

  @override
  State<ChatPageGroup> createState() => _ChatPageGroupState();
}

class _ChatPageGroupState extends State<ChatPageGroup>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ChatMessageBottomBarStudentProvider _chatMessageBottomBarProvider =
      Get.put(ChatMessageBottomBarStudentProvider());
  final player = AudioPlayer();
  final Map? dataProvider = Get.put(TokenProvider()).userData;

  int page = 0;
  _getChatOfStudent() {
    EasyLoading.show(status: "جار جلب البيانات");
    ChatGroupListAPI().getChatOfGroup(widget.userInfo['_id'], page).then((res) {
      EasyLoading.dismiss();
      if (!res['error']) {
        Get.put(ChatMessageGroupStudentProvider()).addListChat(res["results"]);
      } else {
        EasyLoading.showError(res['message'].toString());
      }
    });
  }

  // final AudioPlayerProvider _audioPlayerProvider =
  //     Get.put(AudioPlayerProvider());
  _checkUserOnline() {
    String uId = widget.userInfo['_id'];
    Map data = {"chat_to": uId};
    Get.put(ChatSocketStudentProvider()).socket.emit('checkOnline', data);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Get.put(ChatMessageGroupStudentProvider()).currentChatSender =
        dataProvider!['_id'];
    Get.put(ChatMessageGroupStudentProvider()).currentGroupId =
        widget.userInfo['_id'];
    _checkUserOnline();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        page++;
        _getChatOfStudent();
      }

      if (_scrollController.position.pixels >= 200) {
        Get.put(ChatMessageGroupStudentProvider()).isShow(true);
      } else {
        Get.put(ChatMessageGroupStudentProvider()).isShow(false);
      }
    });
    //
    Get.put(ChatSocketStudentProvider())
        .socket
        .emit('groupJoin', widget.userInfo['_id']);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Logger().i("app in resumed");
        _checkUserOnline();
        Get.put(ChatSocketStudentProvider())
            .socket
            .emit('groupJoin', widget.userInfo['_id']);
        break;
      case AppLifecycleState.inactive:
        Logger().i("app in inactive");
        break;
      case AppLifecycleState.paused:
        Logger().i("app in paused");

        break;
      case AppLifecycleState.detached:
        Logger().i("app in detached");
        break;

      case AppLifecycleState.hidden:
        Logger().i("app in hidden");
        break;
    }
  }

  @override
  void dispose() {
    Logger().i("dispose");

    WidgetsBinding.instance.removeObserver(this);
    // notificationProvider.remove();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child:
                  profileImg(widget.contentUrl, widget.userInfo['account_img']),
            ),
            const SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.userInfo['group_name'],
                  style: const TextStyle(fontSize: 15),
                ),
                GetBuilder<ChatMessageGroupStudentProvider>(builder: (val) {
                  return Row(
                    children: [
                      _onlineIconCheck(val.online, widget.userInfo['_id']),
                      const SizedBox(
                        width: 3,
                      ),
                      val.typing['chat_to'] == widget.userInfo['_id']
                          ? const Text(
                              "جار الكتابة...",
                              style: TextStyle(fontSize: 10),
                            )
                          : _onlineWidgetCheck(
                              val.online, widget.userInfo['_id']),
                    ],
                  );
                })
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<ChatMessageGroupStudentProvider>(builder: (val) {
              return Scaffold(
                body: ListView.builder(
                    // separatorBuilder: (BuildContext context, int index) {
                    //   return DateChip(
                    //       date: toDateAndTimeDateTime(val.chat[index]['created_at']-100000,24)
                    //   );
                    // },
                    //
                    itemCount: val.chat.length,
                    controller: _scrollController,
                    reverse: true,
                    itemBuilder: (BuildContext context, int index) =>
                        chatMessageBubbles(val.chat[index], index, player)),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniStartFloat,
                floatingActionButton: val.showFloating
                    ? FloatingActionButton(
                        onPressed: () {
                          _scrollController.animateTo(0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.bounceIn);
                        },
                        mini: true,
                        backgroundColor: MyColor.purple,
                        child: const Icon(Icons.arrow_downward_rounded),
                      )
                    : null,
              );
            }),
          ),
          Builder(builder: (context) {
            return widget.userInfo['is_locked']
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: double.infinity,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade400),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('تم إيقاف إرسال الرسائل من قبل الاستاذ.',
                                    style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 12)),
                                Text('الإرسال متاح للأستاذ فقط.',
                                    style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.lock,
                              color: Colors.grey.shade700,
                              size: 18,
                            )
                          ],
                        )),
                  )
                : widget.isChatOpen
                    ? _bottomContainer()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: double.infinity,
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey.shade400),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('تم إيقاف إرسال الرسائل',
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 12)),
                                    Text(
                                        'إمكانية إرسال الرسائل  من : 5:00 م - 7:00 م.',
                                        style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Icon(
                                  Icons.lock,
                                  color: Colors.grey.shade700,
                                  size: 18,
                                )
                              ],
                            )),
                      );
          }),
        ],
      ),
    );
  }

  static const double iconSize = 20;

  _bottomContainer() {
    return GetBuilder<ChatMessageBottomBarStudentProvider>(builder: (val) {
      return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        // decoration: BoxDecoration(
        //
        // ),
        child: val.isRecording
            ? Row(
                children: [
                  IconButton(
                      onPressed: () => _sendSound(),
                      icon: const Icon(
                        Icons.send_rounded,
                        color: MyColor.purple,
                      )),
                  Expanded(
                    child: Row(
                      children: [
                        Text(secondToTime(val.recordDuration.toInt())),
                        const Spacer(),
                        IconButton(
                            onPressed: val.recordSoundStop,
                            icon: const Icon(
                              Icons.cancel,
                              color: MyColor.red,
                            )),
                        // Expanded(
                        //   child: Column(
                        //     children: [
                        //       RectangleWaveform(
                        //         maxDuration: const Duration(seconds: 60),
                        //         elapsedDuration: Duration(seconds: (60 - (val.current?.duration!.inSeconds ?? 0))),
                        //         samples: val.samples,
                        //         height: 100,
                        //         absolute: true,
                        //         borderWidth: 0.5,
                        //         inactiveBorderColor: Color(0xFFEBEBEB),
                        //         width: MediaQuery.of(context).size.width,
                        //         inactiveColor: Colors.white,
                        //         activeBorderColor: Color(0xFFEBEBEB),
                        //         activeGradient: LinearGradient(
                        //           begin: Alignment.bottomCenter,
                        //           end: Alignment.topCenter,
                        //           colors: [
                        //             Color(0xFFff3701),
                        //             Color(0xFFff6d00),
                        //           ],
                        //           stops: [
                        //             0,
                        //             0.3,
                        //           ],
                        //         ),
                        //       ),
                        //       SizedBox(
                        //         height: 2,
                        //       ),
                        //       RectangleWaveform(
                        //         maxDuration: Duration(seconds: 60),
                        //         elapsedDuration: Duration(seconds: (60 - (val.current?.duration!.inSeconds ?? 0))),
                        //         samples: val.samples,
                        //         height: 50,
                        //         width: MediaQuery.of(context).size.width,
                        //         absolute: true,
                        //         invert: true,
                        //         borderWidth: 0.5,
                        //         inactiveBorderColor: Color(0xFFEBEBEB),
                        //         activeBorderColor: Color(0xFFEBEBEB),
                        //         activeColor: Color(0xFFffbf99),
                        //         inactiveColor: Color(0xFFffbf99),
                        //       ),
                        //     ],
                        //   ),
                        // )
                      ],
                    ),
                  )
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: val.message.text.trim().isNotEmpty
                          ? _sendTextMessage
                          : val.recordSoundStart,
                      icon: val.message.text.trim().isNotEmpty
                          ? const Icon(
                              Icons.send,
                              color: MyColor.purple,
                            )
                          : const Icon(
                              Icons.mic,
                              color: MyColor.purple,
                            )

                      // const Icon(
                      //         Icons.mic,
                      //         color: MyColor.purple,
                      //       )
                      ),
                  Expanded(
                    child: TextFormField(
                      controller: val.message,
                      style: const TextStyle(
                        color: MyColor.black,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (text) {
                        Map data = {
                          "chat_to": widget.userInfo['_id'],
                        };
                        val.changeTextMessage(data);
                      },
                      onTap: val.changeOpen,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12),
                          hintText: "اكتب هنا",
                          errorStyle: const TextStyle(color: MyColor.grayDark),
                          fillColor: MyColor.grayDark.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          //prefixIcon: const Icon(LineIcons.user),
                          filled: true
                          //fillColor: Colors.green
                          ),
                    ),
                  ),
                  val.isOpenOtherItems
                      ? IconButton(
                          onPressed: val.changeOpen,
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: MyColor.purple,
                            size: iconSize,
                          ))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: val.changeOpen,
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: MyColor.purple,
                                  size: iconSize,
                                )),
                            IconButton(
                                onPressed: _pickPDF,
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  color: MyColor.purple,
                                  size: iconSize,
                                )),
                            IconButton(
                                onPressed: _pickCamera,
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: MyColor.purple,
                                  size: iconSize,
                                )),
                            IconButton(
                                onPressed: _pickImage,
                                icon: const Icon(
                                  Icons.image,
                                  color: MyColor.purple,
                                  size: iconSize,
                                )),
                          ],
                        ),
                ],
              ),
      );
    });
  }

  _sendTextMessage() {
    final Map? dataProvider = Get.put(TokenProvider()).userData;
    Map message = {
      "group_message_type": "text",
      "group_message_uuid": const Uuid().v1(),
      "group_message": _chatMessageBottomBarProvider.message.text,
      'group_message_is_deleted': false,
      'isRead': false,
      "group_message_from": {
        "_id": dataProvider!['_id'],
        "account_name": dataProvider['account_name'],
        //"account_img": dataProvider['account_name'],
        "account_mobile": dataProvider['account_mobile']
      },
      //"chat_from": dataProvider!['_id'],
      //"group_replay": null,
      "created_at": DateTime.now().millisecondsSinceEpoch,
      "group_message_url": null,
      "chat_delivered": false,
    };

    Map data = {"message": message, "groupId": widget.userInfo['_id']};

    Get.put(ChatMessageGroupStudentProvider()).addSingleChat(message);
    Get.put(ChatGroupStudentListProvider())
        .addSingleChat(message, widget.userInfo['_id']);
    Get.put(ChatSocketStudentProvider()).socket.emit('groupMessage', data);
    _chatMessageBottomBarProvider.message.clear();
  }

  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> res = await picker.pickMultiImage();
    List<dio.MultipartFile> localPic = [];
    for (int i = 0; i < res.length; i++) {
      final mimeType = lookupMimeType(res[i].path);
      if (getFileType(mimeType) != 'video') {
        localPic.add(dio.MultipartFile.fromFileSync(res[i].path,
            filename: 'pic$i.${getFileExtension(mimeType)}',
            contentType:
                MediaType(getFileType(mimeType), getFileExtension(mimeType))));
      }
    }
    if (localPic.isNotEmpty) {
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      dio.FormData data = dio.FormData.fromMap({
        "group_message_type": "image",
        "group_message_uuid": const Uuid().v1(),
        "group_message": null,
        'group_message_is_deleted': false,
        'isRead': false,
        "group_message_from": {
          "_id": dataProvider!['_id'],
          "account_name": dataProvider['account_name'],
          //"account_img": dataProvider['account_name'],
          "account_mobile": dataProvider['account_mobile']
        },
        "group_message_imgs": localPic,
        "group_message_group_id": widget.userInfo['_id'],
        "group_chat_replay": null,
        "created_at": DateTime.now().millisecondsSinceEpoch,
        "group_message_url": null,
        "chat_delivered": false,
      });

      AddChatFilesAPI().addImagesGroup(data);
    }
  }

  Future _pickCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? res = await picker.pickImage(source: ImageSource.camera);
    List<dio.MultipartFile> localPic = [];
    if (res != null) {
      localPic.add(dio.MultipartFile.fromFileSync(res.path,
          filename: 'pic$res.jpg', contentType: MediaType('image', 'jpg')));

      final Map? dataProvider = Get.put(TokenProvider()).userData;
      dio.FormData data = dio.FormData.fromMap({
        "group_message_type": "image",
        "group_message_uuid": const Uuid().v1(),
        "group_message": null,
        'group_message_is_deleted': false,
        'isRead': false,
        "group_message_from": {
          "_id": dataProvider!['_id'],
          "account_name": dataProvider['account_name'],
          //"account_img": dataProvider['account_name'],
          "account_mobile": dataProvider['account_mobile']
        },
        "group_message_imgs": localPic,
        "group_message_group_id": widget.userInfo['_id'],
        "group_chat_replay": null,
        "created_at": DateTime.now().millisecondsSinceEpoch,
        "group_message_url": null,
        "chat_delivered": false,
      });

      AddChatFilesAPI().addImagesGroup(data);
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.count == 1) {
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      final pickedFile = result.files.single;

      if (pickedFile.extension == 'pdf') {
        // Handle the selected PDF file.
        final String? filePath = pickedFile.path;
        if (filePath != null) {
          dio.FormData data = dio.FormData.fromMap({
            "group_message_type": "pdf",
            "group_message_uuid": const Uuid().v1(),
            "group_message": null,
            'group_message_is_deleted': false,
            'isRead': false,
            "group_message_from": {
              "_id": dataProvider!['_id'],
              "account_name": dataProvider['account_name'],
              "account_mobile": dataProvider['account_mobile']
            },
            "group_message_imgs": null,
            "group_message_group_id": widget.userInfo['_id'],
            "group_chat_replay": null,
            "created_at": DateTime.now().millisecondsSinceEpoch,
            "group_message_url": dio.MultipartFile.fromFileSync(filePath,
                filename: 'pdfFile.pdf',
                contentType: MediaType('application', 'pdf')),
            "chat_delivered": false,
          });

          AddChatFilesAPI().addImagesGroup(data);
        }
      } else {
        // Show an error message if the selected file is not a PDF.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("خطا في اختيار الملف"),
              content: const Text("يرجى اختيار ملف pdf و ليس صورة"),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle file selection cancellation or multiple file selection if needed.
    }
  }

  Future _sendSound() async {
    String? recordPath = await _chatMessageBottomBarProvider.recordSoundStop();
    if (recordPath != null) {
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      dio.FormData data = dio.FormData.fromMap({
        "group_message_type": "audio",
        "group_message_uuid": const Uuid().v1(),
        "group_message": null,
        'group_message_is_deleted': false,
        'isRead': false,
        "group_message_from": {
          "_id": dataProvider!['_id'],
          "account_name": dataProvider['account_name'],
          //"account_img": dataProvider['account_name'],
          "account_mobile": dataProvider['account_mobile']
        },
        "group_message_imgs": null,
        "group_message_group_id": widget.userInfo['_id'],
        "group_chat_replay": null,
        "created_at": DateTime.now().millisecondsSinceEpoch,
        "group_message_url": dio.MultipartFile.fromFileSync(recordPath,
            filename: 'audio.m4a', contentType: MediaType('audio', 'aac')),
        "chat_delivered": false,
      });

      AddChatFilesAPI().addImagesGroup(data);
    }
  }
}

Widget _onlineWidgetCheck(Map online, String id) {
  if (online.isNotEmpty) {
    if (online['isOnline'] && online['id'] == id) {
      return const Text(
        "نشط",
        style: TextStyle(fontSize: 10),
      );
    } else {
      return Text(
        lastSeenTime(online['date']),
        //"اخر ضهور $data ",
        style: const TextStyle(fontSize: 10),
      );
    }
  } else {
    return Container();
  }
}

Widget _onlineIconCheck(Map online, String id) {
  if (online.isNotEmpty) {
    if (online['isOnline'] && online['id'] == id) {
      return const Icon(
        Icons.circle,
        size: 10,
        color: Colors.green,
      );
    } else {
      return Container();
    }
  } else {
    return Container();
  }
}

// _d(){
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       RectangleWaveform(
//         maxDuration: maxDuration,
//         elapsedDuration: elapsedDuration,
//         samples: samples,
//         height: 100,
//         absolute: true,
//         borderWidth: 0.5,
//         inactiveBorderColor: borderColor,
//         width: MediaQuery.of(context).size.width,
//         inactiveColor: Colors.white,
//         activeBorderColor: borderColor,
//         activeGradient: LinearGradient(
//           begin: Alignment.bottomCenter,
//           end: Alignment.topCenter,
//           colors: [
//             Color(0xFFff3701),
//             Color(0xFFff6d00),
//           ],
//           stops: [
//             0,
//             0.3,
//           ],
//         ),
//       ),
//       const SizedBox(
//         height: 2,
//       ),
//       RectangleWaveform(
//         maxDuration: maxDuration,
//         elapsedDuration: elapsedDuration,
//         samples: samples,
//         height: 50,
//         width: MediaQuery.of(context).size.width,
//         absolute: true,
//         invert: true,
//         borderWidth: 0.5,
//         inactiveBorderColor: borderColor,
//         activeBorderColor: borderColor,
//         activeColor: minoractiveColor,
//         inactiveColor: minorinactiveColor,
//       ),
//       // sizedBox,
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               audioPlayer.fixedPlayer!.pause();
//             },
//             child: const Icon(
//               Icons.pause,
//             ),
//           ),
//           sizedBox,
//           ElevatedButton(
//             onPressed: () {
//               audioPlayer.fixedPlayer!.resume();
//             },
//             child: const Icon(Icons.play_arrow),
//           ),
//           sizedBox,
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 audioPlayer.fixedPlayer!
//                     .seek(const Duration(milliseconds: 0));
//               });
//             },
//             child: const Icon(Icons.replay_outlined),
//           ),
//         ],
//       )
//     ],
//   );
// }
