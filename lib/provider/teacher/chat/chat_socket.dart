import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../static_files/my_url.dart';
import '../../auth_provider.dart';
import 'chat_message.dart';

class ChatSocketProvider extends GetxController {
  late IO.Socket socket;
  void changeSocket(Map? dataProvider){
    Map<String, String> _headers = {"Authorization": dataProvider!['token']};
    socket = IO.io(socketURL + 'chat', IO.OptionBuilder().setTransports(['websocket']).setAuth(_headers).build());
    socket.on('message', (_data){
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      bool isSender = _data['chat_from'] == dataProvider!['_id'];
      if(_data["chat_message_type"] == "text"){
        if(isSender) {
          Get.put(ChatMessageProvider()).changeMessageSenderStatus(_data);
        } else {
          Get.put(ChatMessageProvider()).addSingleChat(_data);
        }
      }else{
        Get.put(ChatMessageProvider()).addSingleChat(_data);
      }
    });
    socket.on('groupMessage', (_data){
      _data["isRead"] = false;
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      bool isSender = _data['group_message_from']['_id'] == dataProvider!['_id'];
      if(_data["group_message_type"] == "text"){
        if(isSender) {
          Get.put(ChatMessageGroupProvider()).changeMessageSenderStatus(_data);
        } else {
          Get.put(ChatMessageGroupProvider()).addSingleChat(_data);
        }
      }else{
        Get.put(ChatMessageGroupProvider()).addSingleChat(_data);
      }
    });
    socket.on('responseRemoveMessage', (_data){
      Logger().i('response deleted');
      if(_data['chat_message_is_deleted']) {
        Get.put(ChatMessageProvider()).deleteMessageById(_data['_id']);
      }
    });
    socket.on('groupResponseRemoveMessage', (_data){
      Logger().i('response deleted');
      if(_data['group_message_is_deleted']) {
        Get.put(ChatMessageGroupProvider()).deleteMessageById(_data['_id']);
      }
    });
    socket.on('getTyping', (data) {
      Get.put(ChatMessageProvider()).chatTyping(data);
    });
    socket.on('online', (data) {
      Get.put(ChatMessageProvider()).userOnlineCheck(data);
    });
    update();
  }
}
