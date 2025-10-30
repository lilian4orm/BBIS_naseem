import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../static_files/my_url.dart';
import '../../auth_provider.dart';
import 'chat_message.dart';

class ChatSocketStudentProvider extends GetxController {
  IO.Socket? _socket;

  IO.Socket get socket {
    // Lazy initialize socket if needed
    if (_socket == null) {
      changeSocket(null);
    }
    return _socket!;
  }

  void changeSocket(Map? dataProvider) {
    final Map? creds = dataProvider ?? Get.put(TokenProvider()).userData;
    if (creds == null) return;
    Map<String, String> headers = {"Authorization": creds['token']};
    _socket = IO.io(
        '${socketURL}chat',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth(headers)
            .build());
    _socket!.on('message', (data) {
      final Map? dataProvider = Get.put(TokenProvider()).userData;
      dynamic from = data['chat_from'];
      String? fromId;
      if (from is Map) {
        fromId = from['_id']?.toString();
      } else {
        fromId = from?.toString();
      }
      bool isSender = fromId == dataProvider!['_id'];
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
    _socket!.on('groupMessage', (data) {
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
    _socket!.on('responseRemoveMessage', (data) {
      Logger().i('response deleted');
      if (data['chat_message_is_deleted']) {
        Get.put(ChatMessageStudentProvider()).deleteMessageById(data['_id']);
      }
    });
    _socket!.on('groupResponseRemoveMessage', (data) {
      Logger().i('response deleted');
      if (data['group_message_is_deleted']) {
        Get.put(ChatMessageGroupStudentProvider())
            .deleteMessageById(data['_id']);
      }
    });
    _socket!.on('getTyping', (data) {
      Get.put(ChatMessageStudentProvider()).chatTyping(data);
    });
    _socket!.on('online', (data) {
      Get.put(ChatMessageStudentProvider()).userOnlineCheck(data);
    });
    update();
  }
}
