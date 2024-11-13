import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../static_files/my_url.dart';
import '../../auth_provider.dart';
import 'chat_message.dart';

class ChatSocketStudentProvider extends GetxController {
  late IO.Socket socket;
  void changeSocket(Map? dataProvider) {
    Map<String, String> headers = {"Authorization": dataProvider!['token']};
    socket = IO.io(
        '${socketURL}chat',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth(headers)
            .build());
    socket.on('message', (data) {
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      bool isSender = data['chat_from'] == dataProvider!['_id'];
      if (data["chat_message_type"] == "text") {
        if (isSender) {
          Get.put(ChatMessageStudentProvider()).changeMessageSenderStatus(data);
        } else {
          Get.put(ChatMessageStudentProvider()).addSingleChat(data);
        }
      } else {
        Get.put(ChatMessageStudentProvider()).addSingleChat(data);
      }
    });
    socket.on('groupMessage', (data) {
      data["isRead"] = false;
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      bool isSender = data['group_message_from']['_id'] == dataProvider!['_id'];
      if (data["group_message_type"] == "text") {
        if (isSender) {
          Get.put(ChatMessageGroupStudentProvider())
              .changeMessageSenderStatus(data);
        } else {
          Get.put(ChatMessageGroupStudentProvider()).addSingleChat(data);
        }
      } else {
        Get.put(ChatMessageGroupStudentProvider()).addSingleChat(data);
      }
    });
    socket.on('responseRemoveMessage', (data) {
      Logger().i('response deleted');
      if (data['chat_message_is_deleted']) {
        Get.put(ChatMessageStudentProvider()).deleteMessageById(data['_id']);
      }
    });
    socket.on('groupResponseRemoveMessage', (data) {
      Logger().i('response deleted');
      if (data['group_message_is_deleted']) {
        Get.put(ChatMessageGroupStudentProvider())
            .deleteMessageById(data['_id']);
      }
    });
    socket.on('getTyping', (data) {
      Get.put(ChatMessageStudentProvider()).chatTyping(data);
    });
    socket.on('online', (data) {
      Get.put(ChatMessageStudentProvider()).userOnlineCheck(data);
    });
    update();
  }
}
