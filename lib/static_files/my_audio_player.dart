import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:line_icons/line_icons.dart';

import 'package:rxdart/rxdart.dart' as Rx;

import 'my_color.dart';

class MyAudioPlayer extends StatefulWidget {
  final Map data;
  final int index;
  final AudioPlayer player;
  final String urlAudio;
  final VoidCallback? onDelete;
  const MyAudioPlayer(
      {Key? key,
      required this.data,
      required this.index,
      required this.player,
      required this.urlAudio,
      this.onDelete})
      : super(key: key);

  @override
  State<MyAudioPlayer> createState() => _MyAudioPlayerState();
}

class _MyAudioPlayerState extends State<MyAudioPlayer> {
  late Stream<DurationState> _durationState;
  final player = AudioPlayer();
  _init() async {
    await player.setUrl(widget.urlAudio);

    //_audioPlayerProvider.addToPlayer(Get.put(ChatStudentListProvider()).contentUrl + widget.data['chat_url']);
    //await _audioPlayerProvider.player.setUrl(Get.put(ChatStudentListProvider()).contentUrl + widget.data['chat_url']);
  }

  @override
  void initState() {
    _init();
    _durationState =
        Rx.Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
            player.positionStream,
            player.playbackEventStream,
            (position, playbackEvent) => DurationState(
                  progress: position,
                  buffered: playbackEvent.bufferedPosition,
                  total: playbackEvent.duration!,
                ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onDelete != null
          ? () {
              Get.bottomSheet(
                Container(
                  color: MyColor.white0,
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.onDelete?.call();
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
              );
            }
          : null,
      child: Row(
        children: [
          IconButton(
              onPressed: () async {
                if (player.playing) {
                  player.pause();
                } else {
                  //
                  //await player.setUrl(url);
                  //await _audioPlayerProvider.setAudio(Get.put(ChatStudentListProvider()).contentUrl + data['chat_url']);
                  player.play();
                }
                setState(() {});
              },
              icon: player.playing
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow)),
          SizedBox(
            width: Get.width / 2.8,
            child: StreamBuilder<DurationState>(
              stream: _durationState,
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final progress = durationState?.progress ?? Duration.zero;
                final buffered = durationState?.buffered ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;
                return ProgressBar(
                  progress: progress,
                  buffered: buffered,
                  total: total,
                  onSeek: (duration) {
                    player.seek(duration);
                  },
                );
              },
            ),
          ),
          IconButton(
              onPressed: () {
                player.seek(const Duration(seconds: 0));
                player.stop();
                setState(() {});
              },
              icon: const Icon(Icons.stop)),
          IconButton(
              onPressed: () async {
                if (player.speed == 1.5) {
                  await player.setSpeed(1.0);
                } else {
                  await player.setSpeed(1.5);
                }
              },
              icon: const Icon(CommunityMaterialIcons.play_speed)),
        ],
      ),
    );
  }
}

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
