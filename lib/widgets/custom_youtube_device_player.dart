import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CustomYoutubeDevicePlayer extends StatefulWidget {
  final String videoId;

  CustomYoutubeDevicePlayer({
    this.videoId,
  });

  @override
  _CustomYoutubeDevicePlayerState createState() =>
      _CustomYoutubeDevicePlayerState();
}

class _CustomYoutubeDevicePlayerState extends State<CustomYoutubeDevicePlayer> {
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
    );
  }
}
