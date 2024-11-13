import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

// class Auth extends GetxController{
//
// }
class AudioPlayerProvider extends GetxController {
  final player = AudioPlayer(handleInterruptions: true);

  addToPlayer(String url) async {
    await player.setUrl(url);
    update();
  }

}