import 'package:daku/models/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'custom_thumbnail.dart';
import 'custom_youtube_device_player.dart';

class PhotoBrowser extends StatefulWidget {
  final List<Media> photoAssetPaths;
  final int visiblePhotoIndex;
  final Function prevImage;
  final Function nextImage;

  PhotoBrowser({
    this.photoAssetPaths,
    this.visiblePhotoIndex,
    this.prevImage,
    this.nextImage,
  });

  @override
  _PhotoBrowserState createState() => _PhotoBrowserState();
}

class _PhotoBrowserState extends State<PhotoBrowser> {
  int visiblePhotoIndex;
  Function nextImage;
  Function prevImage;

  @override
  void initState() {
    super.initState();
    visiblePhotoIndex = widget.visiblePhotoIndex;
    prevImage = widget.prevImage;
    nextImage = widget.nextImage;
  }

  @override
  void didUpdateWidget(PhotoBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visiblePhotoIndex != oldWidget.visiblePhotoIndex) {
      setState(() {
        visiblePhotoIndex = widget.visiblePhotoIndex;
      });
    }
  }

  void _prevImage() {
    prevImage();
  }

  void _nextImage() {
    nextImage();
  }

  Widget _buildPhotoControls() {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new GestureDetector(
          onTap: _prevImage,
          child: new FractionallySizedBox(
            widthFactor: 0.3,
            heightFactor: 1.0,
            alignment: Alignment.topLeft,
            child: new Container(
              color: Colors.transparent,
            ),
          ),
        ),
        new GestureDetector(
          onTap: _nextImage,
          child: new FractionallySizedBox(
            widthFactor: 0.3,
            heightFactor: 1.0,
            alignment: Alignment.topRight,
            child: new Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: new SelectedPhotoIndicator(
            photoCount: widget.photoAssetPaths.length,
            visiblePhotoIndex: visiblePhotoIndex,
          ),
        ),
        _buildPhotoControls(),
      ],
    );
  }
}

class SelectedPhotoIndicator extends StatelessWidget {
  final int photoCount;
  final int visiblePhotoIndex;

  SelectedPhotoIndicator({
    this.visiblePhotoIndex,
    this.photoCount,
  });

  Widget _buildInactiveIndicator(BuildContext context) {
    return new Expanded(
      child: new Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
        child: new Container(
          height: 5.0,
          decoration: new BoxDecoration(
            color: Theme.of(context).indicatorColor,
            borderRadius: new BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIndicator(BuildContext context) {
    return new Expanded(
      child: new Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
        child: new Container(
          height: 5.0,
          decoration: new BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: new BorderRadius.circular(2.5),
            boxShadow: [
              new BoxShadow(
                color: const Color(0x22000000),
                blurRadius: 2.0,
                spreadRadius: 0.0,
                offset: const Offset(0.0, 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIndicators(BuildContext context) {
    List<Widget> indicators = [];
    for (int i = 0; i < photoCount; i++) {
      indicators.add(
        i == visiblePhotoIndex
            ? _buildActiveIndicator(context)
            : _buildInactiveIndicator(context),
      );
    }
    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: new Row(
        children: _buildIndicators(context),
      ),
    );
  }
}
