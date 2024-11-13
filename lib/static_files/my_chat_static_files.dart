import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../provider/auth_provider.dart';
import '../provider/teacher/chat/chat_all_list_items.dart';
import '../provider/teacher/chat/chat_socket.dart';
import 'chat_bubbles/bubbles/bubble_special_three.dart';
import 'my_audio_player.dart';
import 'my_color.dart';
import 'my_image_grid.dart';
import 'my_pdf_viewr.dart';
import 'my_times.dart';

const EdgeInsets padding = EdgeInsets.fromLTRB(10, 1, 10, 1);
const EdgeInsets _margin = EdgeInsets.only(bottom: 10);
const EdgeInsets _margin2 = EdgeInsets.only(bottom: 10, left: 15, right: 15);

Widget profileImg(String contentUrl, String? img) {
  if (img == null) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: SizedBox(
          width: 26,
          child: Image.asset("assets/img/logo.png", fit: BoxFit.fill)),
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

Widget chatMessageBubbles(Map data, int index, AudioPlayer player) {
  if (data['chat_message_is_deleted']) {
    return _deletedMessage(data);
  } else {
    if (data['chat_message_type'] == 'text') {
      return _textChatMessage(data, index);
    } else if (data['chat_message_type'] == 'image') {
      return _imgChatMessage(data, index);
    } else if (data['chat_message_type'] == 'video') {
      return const Text("video");
    } else if (data['chat_message_type'] == 'audio') {
      String urlAudio =
          Get.put(ChatStudentListProvider()).contentUrl + data['chat_url'];
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      bool isSender = data['chat_from'] == dataProvider!['_id'];
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSender
                      ? MyColor.yellow.withOpacity(0.15)
                      : MyColor.purple.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: SizedBox(
                  child: MyAudioPlayer(
                    data: data,
                    index: index,
                    player: player,
                    urlAudio: urlAudio,
                    onDelete: () {
                      final Map? dataProvider =
                          Get.put(TokenProvider()).userData;
                      bool isSender = data['chat_from'] == dataProvider!['_id'];

                      if (isSender) {
                        _deleteMessage(data, index);
                      }
                    },
                  ),
                ),
              ),
              if (data['created_at'] != null)
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    toDateAndTime(data['created_at'], 12),
                    style: const TextStyle(fontSize: 8),
                  ),
                ),
            ],
          ),
        ],
      );
    } else if (data['chat_message_type'] == 'pdf') {
      return _pdfChatMessage(data, index);
    } else {
      return const Text("ERROR");
    }
  }
}

Widget _deletedMessage(Map data) {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = data['chat_from'] == dataProvider!['_id'];
  return BubbleSpecialThree(
    //delivered: true,
    text: "تم مسح الرسالة",
    tail: false,
    isSender: isSender,
    color: Colors.grey.shade50,
    textStyle: TextStyle(
      fontSize: 13,
      color: Colors.grey.shade900,
      fontStyle: FontStyle.italic,
    ),
    //MyColor.purple
  );
}

Widget _textChatMessage(Map data, int index) {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = data['chat_from'] == dataProvider!['_id'];
  return GestureDetector(
    onLongPress: () {
      isSender
          ? Get.bottomSheet(
              Container(
                color: MyColor.white0,
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: data['chat_message']));
                        Get.back();
                      },
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LineIcons.copy),
                          Text("نسخ"),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        isSender ? _deleteMessage(data, index) : null;
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSender) const Icon(LineIcons.alternateTrashAlt),
                          const Text("حذف")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Get.bottomSheet(
              Container(
                color: MyColor.white0,
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: data['chat_message']));
                        Get.back();
                      },
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LineIcons.copy),
                          Text("نسخ"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
    },
    child: Container(
      margin: _margin,
      child: BubbleSpecialThree(
        seen: isSender ? data['chat_message_isRead'] : false,
        //delivered: _data['chat_delivered'] == null ?true : false,
        sent: !isSender
            ? false
            : data['chat_delivered'] == null
                ? true
                : false,
        text: data['chat_message'],
        time: toDateAndTime(data['created_at'], 12),
        isSender: isSender,
        color: isSender
            ? MyColor.yellow.withOpacity(0.15)
            : MyColor.purple.withOpacity(0.20),
        textStyle: const TextStyle(
          fontSize: 15,
          color: MyColor.black,
        ),
        //MyColor.purple
      ),
    ),
  );
}

Widget _pdfChatMessage(Map data, int index) {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = data['chat_from'] == dataProvider!['_id'];
  return GestureDetector(
    onLongPress: () {
      isSender
          ? Get.bottomSheet(
              Container(
                color: MyColor.white0,
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        isSender ? _deleteMessage(data, index) : null;
                      },
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LineIcons.alternateTrashAlt),
                          Text("حذف")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null;
    },
    onTap: () => Get.to(() => PdfViewer(
        url: Get.put(ChatStudentListProvider()).contentUrl + data['chat_url'])),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
            margin: _margin2,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: isSender
                    ? MyColor.yellow.withOpacity(0.15)
                    : MyColor.purple.withOpacity(0.20),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/img/pdf.svg",
                    width: Get.width / 5,
                    //_data['chat_url'],
                    semanticsLabel: ''),
                if (data['created_at'] != null)
                  Text(
                    toDateAndTime(data['created_at'], 12),
                    style: const TextStyle(fontSize: 11),
                  )
              ],
            )

            // BubbleSpecialThree(
            //   seen: _data['chat_message_isRead'],
            //   //delivered: _data['chat_delivered'] == null ?true : false,
            //   sent: _data['chat_delivered'] == null ?true : false ,
            //   text: _data['chat_message'],
            //   time: toDateAndTime(_data['created_at'],12),
            //   isSender: isSender,
            //   color: isSender
            //       ? MyColor.yellow.withOpacity(0.15)
            //       : MyColor.purple.withOpacity(0.20),
            //   textStyle: const TextStyle(
            //     fontSize: 15,
            //     color: MyColor.black,
            //   ),
            //
            //   //MyColor.purple
            // ),
            ),
      ],
    ),
  );
}

Widget _audioChatMessage(Map data, int index) {
  //return MyAudioPlayer(data: _data,);
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = data['chat_from'] == dataProvider!['_id'];
  return GestureDetector(
    onLongPress: () {
      Get.bottomSheet(
        Container(
          color: MyColor.white0,
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  isSender ? _deleteMessage(data, index) : null;
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(LineIcons.alternateTrashAlt), Text("حذف")],
                ),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(LineIcons.copy), Text("نسخ")],
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(LineIcons.reply), Text("رد")],
              ),
            ],
          ),
        ),
      );
    },
    onTap: () => Get.to(() => PdfViewer(
        url: Get.put(ChatStudentListProvider()).contentUrl + data['chat_url'])),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
            margin: _margin2,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: isSender
                    ? MyColor.yellow.withOpacity(0.15)
                    : MyColor.purple.withOpacity(0.20),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/img/pdf.svg",
                    width: Get.width / 5,
                    //_data['chat_url'],
                    semanticsLabel: ''),
                if (data['created_at'] != null)
                  Text(
                    toDateAndTime(data['created_at'], 12),
                    style: const TextStyle(fontSize: 11),
                  )
              ],
            )

            // BubbleSpecialThree(
            //   seen: _data['chat_message_isRead'],
            //   //delivered: _data['chat_delivered'] == null ?true : false,
            //   sent: _data['chat_delivered'] == null ?true : false ,
            //   text: _data['chat_message'],
            //   time: toDateAndTime(_data['created_at'],12),
            //   isSender: isSender,
            //   color: isSender
            //       ? MyColor.yellow.withOpacity(0.15)
            //       : MyColor.purple.withOpacity(0.20),
            //   textStyle: const TextStyle(
            //     fontSize: 15,
            //     color: MyColor.black,
            //   ),
            //
            //   //MyColor.purple
            // ),
            ),
      ],
    ),
  );
}

Widget _imgChatMessage(Map data, int index) {
  //imageGrid(Get.put(ChatStudentListProvider()).contentUrl,_data['chat_message_imgs'])
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = data['chat_from'] == dataProvider!['_id'];
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment:
        isSender ? MainAxisAlignment.start : MainAxisAlignment.end,
    children: [
      Expanded(
        child: GestureDetector(
          onLongPress: () {
            isSender
                ? Get.bottomSheet(
                    Container(
                      color: MyColor.white0,
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              isSender ? _deleteMessage(data, index) : null;
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LineIcons.alternateTrashAlt),
                                Text("حذف")
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null;
          },
          child: Container(
              margin: _margin2,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: isSender
                      ? MyColor.yellow.withOpacity(0.15)
                      : MyColor.purple.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  imageGridChat(Get.put(ChatStudentListProvider()).contentUrl,
                      data['chat_message_imgs']),
                  if (data['created_at'] != null)
                    Text(
                      toDateAndTime(data['created_at'], 12),
                      style: const TextStyle(fontSize: 11),
                    )
                ],
              )

              // BubbleSpecialThree(
              //   seen: _data['chat_message_isRead'],
              //   //delivered: _data['chat_delivered'] == null ?true : false,
              //   sent: _data['chat_delivered'] == null ?true : false ,
              //   text: _data['chat_message'],
              //   time: toDateAndTime(_data['created_at'],12),
              //   isSender: isSender,
              //   color: isSender
              //       ? MyColor.yellow.withOpacity(0.15)
              //       : MyColor.purple.withOpacity(0.20),
              //   textStyle: const TextStyle(
              //     fontSize: 15,
              //     color: MyColor.black,
              //   ),
              //
              //   //MyColor.purple
              // ),
              ),
        ),
      ),
    ],
  );
}

_deleteMessage(Map data, int index) {
  Map messageId = {
    "messageId": data['_id'],
    "chat_from": data['chat_from'],
    "chat_to": data['chat_to']
  };
  Get.defaultDialog(
      title: "حذف الرسالة",
      content: const Text("سيتم حذف الرسالة,هل انت متاكد؟"),
      confirm: MaterialButton(
        onPressed: () {
          Get.put(ChatSocketProvider()).socket.emit('removeMessage', messageId);
          Get.back();
          Get.back();
          //index
        },
        color: MyColor.red,
        textColor: MyColor.white0,
        child: const Text("حذف"),
      ));
}
