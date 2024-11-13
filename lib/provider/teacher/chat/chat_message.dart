import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'chat_socket.dart';
import 'package:record/record.dart';

class ChatMessageProvider extends GetxController {
  List chat = [];
  Map typing = {};
  Map online = {};
  String? currentChatReciver;
  String? currentChatSender;
  bool showFloating = false;
  void isShow(bool bool) {
    if (showFloating != bool) {
      showFloating = bool;
      update();
    }
  }

  String contentUrl = '';
  void addListChat(List data) {
    chat.addAll(data);
    update();
  }

  void addSingleChat(Map data) {
    if (data['chat_from'] == currentChatReciver ||
        data['chat_from'] == currentChatSender) {
      chat.insert(0, data);
      update();
    }
  }

  void changeMessageSenderStatus(Map data) {
    //chat.where((element) => element['chat_uuid']);
    chat.removeWhere((item) => item['chat_uuid'] == data['chat_uuid']);
    chat.insert(0, data);
    // Logger().i(singleChat);
    // singleChat['_id'] = _data['_id'];
    // singleChat['created_at'] = _data['created_at'];
    // singleChat['chat_message_imgs'] = _data['chat_message_imgs'];
    // singleChat['chat_delivered'] = null;
    update();
  }

  void deleteMessageById(String id) {
    Logger().i('kddddddddd');
    final singleChat = chat.firstWhere((item) => item['_id'] == id);
    singleChat['chat_message_is_deleted'] = true;
    update();
  }

  void chatTyping(Map data) {
    typing = data;
    if (typing.isNotEmpty) {
      Timer(const Duration(seconds: 1), () {
        typing.clear();
        update();
      });
    }
    update();
  }

  void userOnlineCheck(Map data) {
    online = data;
    update();
  }

  bool isLoading = true;
  void changeLoading(bool isLoadingR) {
    isLoading = isLoadingR;
    update();
  }

  void clear() {
    chat.clear();
  }
}

class ChatMessageGroupProvider extends GetxController {
  List chat = [];
  Map typing = {};
  Map online = {};
  bool showFloating = false;
  String? currentGroupId;
  String? currentChatSender;
  void isShow(bool bool) {
    if (showFloating != bool) {
      showFloating = bool;
      update();
    }
  }

  String contentUrl = '';
  void addListChat(List data) {
    chat.addAll(data);
    update();
  }

  void addSingleChat(Map data) {
    if (data["group_message_group_id"] == currentGroupId ||
        data["group_message_from"]["_id"] == currentChatSender) {
      chat.insert(0, data);
      update();
    }
  }

  void changeMessageSenderStatus(Map data) {
    //chat.where((element) => element['chat_uuid']);
    chat.removeWhere(
        (item) => item['group_message_uuid'] == data['group_message_uuid']);
    chat.insert(0, data);
    // final singleChat = chat.firstWhere((item) => item['chat_uuid'] == _data['chat_uuid']);
    // singleChat['_id'] = _data['_id'];
    // singleChat['created_at'] = _data['created_at'];
    // singleChat['chat_message_imgs'] = _data['chat_message_imgs'];
    // singleChat['chat_delivered'] = null;
    update();
  }

  void deleteMessageById(String id) {
    final singleChat = chat.firstWhere((item) => item['_id'] == id);
    singleChat['group_message_is_deleted'] = true;
    update();
  }

  void chatTyping(Map data) {
    typing = data;
    if (typing.isNotEmpty) {
      Timer(const Duration(seconds: 1), () {
        typing.clear();
        update();
      });
    }
    update();
  }

  void userOnlineCheck(Map data) {
    online = data;
    update();
  }

  bool isLoading = true;
  void changeLoading(bool isLoadingR) {
    isLoading = isLoadingR;
    update();
  }

  void clear() {
    chat.clear();
  }
}

class ChatMessageBottomBarProvider extends GetxController {
  TextEditingController message = TextEditingController();
  bool isOpenOtherItems = false;
  bool isRecording = false;

  final record = AudioRecorder();
  Amplitude? amplitude;
  Timer? timer;
  Timer? ampTimer;
  double recordDuration = 0;
  void changeTextMessage(Map data) {
    Get.put(ChatSocketProvider()).socket.emit('typing', data);
    update();
  }

  void clearTextMessage() {
    message.clear();
    update();
  }

  void changeOpen() {
    isOpenOtherItems = !isOpenOtherItems;
    update();
  }

  void recordSoundStart() async {
    bool hasPermission = await record.hasPermission();
    if (hasPermission) {
      final appDocDirectory = await getApplicationDocumentsDirectory();

      final filePath = '${appDocDirectory.path}/myFile.m4a';

      await record.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc, // by default
          bitRate: 128000, // by default
          sampleRate: 44100, // by default
        ),
        path: filePath,
      );

      isRecording = await record.isRecording();
      recordDuration = 0;
      _startTimer();
      update();
    }
  }

  void _startTimer() {
    timer?.cancel();
    ampTimer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      recordDuration++;
      update();
    });

    ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      amplitude = await record.getAmplitude();

      update();
    });
  }

  Future<String?> recordSoundStop() async {
    final path = await record.stop();
    timer?.cancel();
    ampTimer?.cancel();
    isRecording = await record.isRecording();
    update();
    return path;
  }
}