import 'package:flutter/material.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class YoutubeViewer extends StatefulWidget {
  final String videoID;
  YoutubeViewer(this.videoID);
  @override
  _YoutubeViewerState createState() => _YoutubeViewerState();
}

class _YoutubeViewerState extends State<YoutubeViewer> {
  // ignore: close_sinks
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoID,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        desktopMode: false, // false for platform design
        autoPlay: true,
        enableCaption: true,
        showVideoAnnotations: false,
        enableJavaScript: true,
        privacyEnhanced: true,
        playsInline: true, // iOS only
      ),
    )..listen((value) {
        if (value.isReady && !value.hasPlayed) {
          _controller
            ..hidePauseOverlay()
            // Uncomment below to stop Autoplay
            // ..play()
            ..hideTopMenu();
        }
      });

    // Uncomment below for device orientation
    // _controller!.onEnterFullscreen = () {
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.landscapeLeft,
    //     DeviceOrientation.landscapeRight,
    //   ]);
    //   log('Entered Fullscreen');
    // };
    // _controller!.onExitFullscreen = () {
    //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //   Future.delayed(const Duration(seconds: 1), () {
    //     _controller!.play();
    //   });
    //   Future.delayed(const Duration(seconds: 5), () {
    //     SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    //   });
    //   log('Exited Fullscreen');
    // };
  }

  @override
  Widget build(BuildContext context) {
    final player = YoutubePlayerIFrame();
    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: AlertDialog(
        insetPadding: EdgeInsets.all(10),
        backgroundColor: Colors.black,
        content: player,
        contentPadding: EdgeInsets.all(0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CloseButton(
              color: Color(0xFFD5D3D3),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
