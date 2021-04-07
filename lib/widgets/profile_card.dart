import 'package:daku/models/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

import 'custom_youtube_device_player.dart';
import 'photos.dart';

class ProfileCard extends StatefulWidget {
  final Post post;

  ProfileCard({
    Key key,
    this.post,
  }) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  int visiblePhotoIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void prevImage() {
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex > 0 ? visiblePhotoIndex - 1 : 0;
    });
  }

  void nextImage() {
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex < widget.post.node.media.length - 1
          ? visiblePhotoIndex + 1
          : visiblePhotoIndex;
    });
  }

  Widget _buildBackground() {
    return new PhotoBrowser(
      photoAssetPaths: widget.post.node.media,
      prevImage: prevImage,
      nextImage: nextImage,
      visiblePhotoIndex: visiblePhotoIndex,
    );
  }

  double getTitleSize() {
    double width = MediaQuery.of(context).size?.width;
    if (width > 500) {
      return 24;
    } else if (width > 350) {
      return width * 0.05;
    } else {
      return width * 0.04;
    }
  }

  double getDescriptionSize() {
    double width = MediaQuery.of(context).size?.width;
    if (width > 500) {
      return 16;
    } else {
      print(width * 0.03);
      return width * 0.03;
    }
  }

  int getMaxLines() {
    double height = MediaQuery.of(context).size?.height;
    print(height);
    return height > 700 ? 6 : 3;
  }

  void _showDialog(context, videoID) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return YoutubeViewer(
          videoID,
        );
      },
    );
  }

  Widget customImage(url, width, [height]) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(5),
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: new Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget ytPlayer(videoID) {
    final url = 'https://i1.ytimg.com/vi/$videoID/hqdefault.jpg';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showDialog(
            context,
            videoID,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Stack(
              children: <Widget>[
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: new Image.network(
                          url,
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 55.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSynopsis() {
    final Media currentMedia = widget.post.node.media[visiblePhotoIndex];
    final isVideoAvailable = currentMedia.videoUrl != null;
    String videoId = isVideoAvailable
        ? YoutubePlayerController.convertUrlToId(currentMedia.videoUrl)
        : '';
    double height = MediaQuery.of(context).size?.height;
    print(currentMedia.url);
    return new Positioned(
      left: 0.0,
      right: 0.0,
      top: 0.0,
      bottom: 0.0,
      child: new Container(
        padding: const EdgeInsets.all(15.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: new Image.asset(
                "assets/images/product-hunt-logo-orange-240.png",
                width: 30,
                height: 30,
              ),
            ),
            isVideoAvailable
                ? Container(
                    width: double.infinity,
                    child: ytPlayer(
                      videoId,
                    ),
                  )
                : customImage(
                    "${currentMedia.url}&auto=compress&codec=mozjpeg&cs=strip&w=450&h=382&fit=max",
                    double.maxFinite,
                    height * 0.3,
                  ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text(
                  widget.post.node.name,
                  style: Theme.of(context).textTheme.headline1.copyWith(
                        fontSize: getTitleSize(),
                      ),
                ),
                SizedBox(
                  height: 10,
                ),
                new Text(
                  widget.post.node.description,
                  style: Theme.of(context).textTheme.subtitle1.copyWith(
                        fontSize: getDescriptionSize(),
                      ),
                  maxLines: getMaxLines(),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(10.0),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildProfileSynopsis(),
            _buildBackground(),
          ],
        ),
      ),
    );
  }
}
