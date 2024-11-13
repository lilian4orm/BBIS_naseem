import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import '../provider/auth_provider.dart';
import '../provider/teacher/chat/chat_all_list_items.dart';
import '../provider/teacher/chat/chat_socket.dart';
import 'chat_bubbles/bubbles/bubble_special_three.dart';
import 'my_audio_player.dart';
import 'my_color.dart';
import 'my_image_grid.dart';
import 'my_pdf_viewr.dart';
import 'my_times.dart';
const EdgeInsets _padding = EdgeInsets.fromLTRB(10, 1, 10, 1);
const EdgeInsets _margin = EdgeInsets.only(bottom: 10);
const EdgeInsets _margin2 = EdgeInsets.only(bottom: 10,left: 15,right: 15);

Widget profileImg(String _contentUrl, String? _img) {
  if (_img == null) {
    return CircleAvatar(
      child: SizedBox(width:26,child: Image.asset("assets/img/ايكونه تطبيق2 (2).png", fit: BoxFit.fill)),
    );
  } else {
    return CircleAvatar(
      //radius: 30,
      backgroundImage: CachedNetworkImageProvider(
        _contentUrl + _img,
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


Widget chatMessageBubbles(Map _data,int index,AudioPlayer player) {
  if (_data['group_message_is_deleted']) {
    return _deletedMessage(_data);
  } else {
    if(_data['group_message_type'] == 'text'){
      return _textChatMessage(_data,index);
    }else if(_data['group_message_type'] == 'image'){
      return _imgChatMessage(_data,index);
    }else if(_data['group_message_type'] == 'video'){
      return const Text("video");
    }else if(_data['group_message_type'] == 'audio'){
      String urlAudio = Get.put(ChatGroupListProvider()).contentUrl + _data['group_message_url'];
      final Map? dataProvider = Get.put(TokenProvider()).userData;

      bool isSender = _data['group_message_from']["_id"]  == dataProvider!['_id'];

      return _audioChat(isSender, _data, index, player, urlAudio);
    }else if(_data['group_message_type'] == 'pdf'){
      return _pdfChatMessage(_data,index);
    }else{
      return const Text("ERROR");
    }
  }
}


Widget _audioChat(bool isSender, Map<dynamic, dynamic> _data, int index, AudioPlayer player, String urlAudio) {

  return Padding(
    padding: const EdgeInsets.symmetric(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:  isSender
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if(!isSender)
              Text(_data['group_message_from']['account_name'],style: TextStyle(fontSize: 11,color: MyColor.black.withOpacity(.7)),),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 15,right: 15),
                  decoration: BoxDecoration(
                      color: isSender
                          ? MyColor.yellow.withOpacity(0.15)
                          : MyColor.purple.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(25)
                  ),

                  child: MyAudioPlayer(data: _data,index:index,player:player,urlAudio: urlAudio,

                      onDelete: (){
                    final Map? dataProvider = Get.put(TokenProvider()).userData;
                    bool isSender = _data['group_message_from']["_id"]  == dataProvider!['_id'];
                    if(isSender){
                      _deleteMessage(_data,index);
                    }
                  }),
                ),
                if(_data['created_at']!=null) Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(toDateAndTime(_data['created_at'],12),style:  TextStyle(fontSize: 10,),),
                )

              ],
            ),

          ],
        ),
        if(!isSender)
          Padding(
            padding: const EdgeInsets.only(left: 8,right: 0),
            child: SizedBox(
                width: 30,
                child: profileImg(Get.put(ChatStudentListProvider()).contentUrl, _data['group_message_from']['account_img'])),
          ),
      ],
    ),
  );
}

Widget _deletedMessage(Map _data) {
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = _data['group_message_from']["_id"]  == dataProvider!['_id'];
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

Widget _textChatMessage(Map _data , int index){
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = _data['group_message_from']["_id"]  == dataProvider!['_id'];
  return GestureDetector(
    onLongPress: (){
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
                  Clipboard.setData(ClipboardData(text: _data['group_message']));
                  Get.back();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LineIcons.copy),
                    Text("نسخ"),
                  ],
                ),

              ),
              GestureDetector(
                onTap: (){
                  isSender
                      ? _deleteMessage(_data,index)
                      : null;
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
      ):Get.bottomSheet(
        Container(
          color: MyColor.white0,
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _data['group_message']));
                  Get.back();
                },
                child: Column(
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
      child: Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if(!isSender)
                Text(_data['group_message_from']['account_name'],style: TextStyle(fontSize: 11,color: MyColor.black.withOpacity(.7)),),
              BubbleSpecialThree(
                seen: _data['isRead'],
                //delivered: _data['chat_delivered'] == null ?true : false,
                sent: _data['chat_delivered'] == null ?true : false ,
                text: _data['group_message'],
                time: toDateAndTime(_data['created_at'],12),
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
            ],
          ),
          if(!isSender)
            Padding(
              padding: const EdgeInsets.only(left: 8,right: 0),
              child: SizedBox(
                width: 30,
                  child: profileImg(Get.put(ChatStudentListProvider()).contentUrl, _data['group_message_from']['account_img'])),
            ),
        ],
      ),
    ),
  );
}

Widget _pdfChatMessage(Map _data , int index){
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = _data['group_message_from']["_id"]  == dataProvider!['_id'];
  return GestureDetector(
    onLongPress: (){
      isSender
      ?Get.bottomSheet(
        Container(
          color: MyColor.white0,
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  isSender
                      ? _deleteMessage(_data,index)
                      : null;
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
      ):null;
    },
    onTap: ()=> Get.to(()=>PdfViewer(url: Get.put(ChatStudentListProvider()).contentUrl + _data['group_message_url'])),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:  isSender
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            if(!isSender)
              Text(_data['group_message_from']['account_name'],style: TextStyle(fontSize: 11,color: MyColor.black.withOpacity(.7)),),

            Container(
                margin: _margin2,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: isSender
                        ? MyColor.yellow.withOpacity(0.15)
                        : MyColor.purple.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: isSender
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                        "assets/img/pdf.svg",
                        width: Get.width/5,
                        //_data['chat_url'],
                        semanticsLabel: ''
                    ),
                    if(_data['created_at']!=null) Text(toDateAndTime(_data['created_at'],12),style: const TextStyle(fontSize: 11),)
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
        if(!isSender)
          Padding(
            padding: const EdgeInsets.only(left: 8,right: 0),
            child: SizedBox(
                width: 30,
                child: profileImg(Get.put(ChatStudentListProvider()).contentUrl, _data['group_message_from']['account_img'])),
          ),


      ],
    ),
  );
}

Widget _audioChatMessage(Map _data , int index){
  //return MyAudioPlayer(data: _data,);
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = _data['chat_from']  == dataProvider!['_id'];
  return GestureDetector(
    onLongPress: (){
      Get.bottomSheet(
        Container(
          color: MyColor.white0,
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  isSender
                      ? _deleteMessage(_data,index)
                      : null;
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LineIcons.alternateTrashAlt),
                    Text("حذف")
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    onTap: ()=> Get.to(()=>PdfViewer(url: Get.put(ChatStudentListProvider()).contentUrl + _data['chat_url'])),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:  isSender
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Container(
            margin: _margin2,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: isSender
                    ? MyColor.yellow.withOpacity(0.15)
                    : MyColor.purple.withOpacity(0.20),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: isSender
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                    "assets/img/pdf.svg",
                    width: Get.width/5,
                    //_data['chat_url'],
                    semanticsLabel: ''
                ),
                if(_data['created_at']!=null) Text(toDateAndTime(_data['created_at'],12),style: const TextStyle(fontSize: 11),)
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

Widget _imgChatMessage(Map _data,int index){
  //imageGrid(Get.put(ChatStudentListProvider()).contentUrl,_data['chat_message_imgs'])
  final Map? dataProvider = Get.put(TokenProvider()).userData;
  bool isSender = _data['group_message_from']["_id"]  == dataProvider!['_id'];
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment:  isSender
        ? MainAxisAlignment.start
        : MainAxisAlignment.end,
    children: [
      Expanded(
        child: GestureDetector(
          onLongPress: (){
            isSender
            ?Get.bottomSheet(
              Container(
                color: MyColor.white0,
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: (){
                        isSender
                            ? _deleteMessage(_data,index)
                            : null;
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
            ):null;
          },

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if(!isSender)
                Text(_data['group_message_from']['account_name'],style: TextStyle(fontSize: 11,color: MyColor.black.withOpacity(.7)),),

              Container(
                  margin: _margin2,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: isSender
                          ? MyColor.yellow.withOpacity(0.15)
                          : MyColor.purple.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    crossAxisAlignment: isSender
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      imageGridChat(Get.put(ChatStudentListProvider()).contentUrl,_data['group_message_imgs']),
                      if(_data['created_at']!=null) Text(toDateAndTime(_data['created_at'],12),style: const TextStyle(fontSize: 11),)
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

        ),
      ),

      if(!isSender)
        Padding(
          padding: const EdgeInsets.only(left: 8,right: 0),
          child: SizedBox(
              width: 30,
              child: profileImg(Get.put(ChatStudentListProvider()).contentUrl, _data['group_message_from']['account_img'])),
        ),

    ],
  );
}

_deleteMessage(Map _data,int index){
  Logger().i('will be removed');
  Map _messageId = {
    "messageId":_data['_id'],
    "groupId": _data['group_message_group_id'],
  };

  //"messageId" -> "6517e04f9ee7e19520a59691"
  //"groupId" -> "650cfbbb90cacd086678686a"
  Get.defaultDialog(
      title: "حذف الرسالة",
      content: const Text("سيتم حذف الرسالة,هل انت متاكد؟"),
      confirm: MaterialButton(
        onPressed: (){
          Get.put(ChatSocketProvider()).socket.emit('groupRemoveMessage', _messageId);
          Get.back();
          Get.back();
        },
        color: MyColor.red,
        textColor: MyColor.white0,
        child: const Text("حذف"),
      )
  );
}



redirection(Map _data,int index){
  Logger().i('will be removed');
  Map _messageId = {
    "messageId":_data['_id'],
    "groupId": _data['group_message_group_id'],
  };
  //"messageId" -> "6517e04f9ee7e19520a59691"
  //"groupId" -> "650cfbbb90cacd086678686a"
  Get.defaultDialog(
      title: "حذف الرسالة",
      content: const Text("سيتم حذف الرسالة,هل انت متاكد؟"),
      confirm: MaterialButton(
        onPressed: (){
          Get.put(ChatSocketProvider()).socket.emit('groupRemoveMessage', _messageId);
          Get.back();
          Get.back();
        },
        color: MyColor.red,
        textColor: MyColor.white0,
        child: const Text("حذف"),
      )
  );
}