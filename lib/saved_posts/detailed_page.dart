import 'package:daku/models/post.dart';
import 'package:daku/saved_posts/web_view.dart';
import 'package:daku/widgets/circular_percent.dart';
import 'package:daku/widgets/transition_animation.dart';
import 'package:daku/widgets/custom_youtube_device_player.dart';
import 'package:daku/widgets/photos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

// ignore: must_be_immutable
class TransPageView extends StatefulWidget {
  TransPageView({this.post});
  Node post;

  @override
  _TransPageViewState createState() => _TransPageViewState();
}

class _TransPageViewState extends State<TransPageView> {
  int visiblePhotoIndex = 0;

  void prevImage() {
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex > 0 ? visiblePhotoIndex - 1 : 0;
    });
  }

  void nextImage() {
    setState(() {
      visiblePhotoIndex = visiblePhotoIndex < widget.post.media.length - 1
          ? visiblePhotoIndex + 1
          : visiblePhotoIndex;
    });
  }

  Widget _buildBackground() {
    return new PhotoBrowser(
      photoAssetPaths: widget.post.media,
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
      return width * 0.03;
    }
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

  Widget customImage(url, width) {
    return Container(
      color: Colors.transparent,
      // padding: EdgeInsets.all(5),
      width: width,
      // height: height * 0.33,
      child: new Image.network(
        url,
        fit: BoxFit.fitWidth,
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
                      // padding: EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width,
                      child: new Image.network(
                        url,
                        fit: BoxFit.fill,
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    print(width);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).highlightColor),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              _buildMedia(),
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                child: _buildBackground(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.name,
                    style: Theme.of(context).textTheme.headline1.copyWith(
                          fontSize: getTitleSize(),
                        ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Description',
                    style: TextStyle(
                      color: Theme.of(context).highlightColor,
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 30),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text(
                      widget.post.description,
                      style: TextStyle(
                        color: Theme.of(context).highlightColor,
                        fontSize: MediaQuery.of(context).size.height * 0.016,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildCircularPercent(context),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    MaterialButton(
                      color: Color.fromRGBO(204, 77, 41, 1),
                      shape: StadiumBorder(),
                      onPressed: () {
                        kIsWeb
                            ? launchURL(widget.post.slug)
                            : Navigator.push(
                                context,
                                SizeTransition1(
                                  WebViewPage(
                                    title: widget.post.name,
                                    url: widget.post.slug,
                                  ),
                                ),
                              );
                      },
                      elevation: 5.0,
                      child: Container(
                        width: 300,
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              padding: EdgeInsets.only(
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/product-hunt-logo-orange-240.png'),
                                ),
                              ),
                            ),
                            Text(
                              'Open on ProductHunt',
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).highlightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void launchURL(slug) async {
    final url = 'https://www.producthunt.com/posts/$slug';
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  _buildMedia() {
    final Media currentMedia = widget.post.media[visiblePhotoIndex];
    final isVideoAvailable = currentMedia.videoUrl != null;
    String videoId = isVideoAvailable
        ? YoutubePlayerController.convertUrlToId(currentMedia.videoUrl)
        : '';
    double height = MediaQuery.of(context).size?.height;
    double width = MediaQuery.of(context).size?.width;
    return Stack(
      children: [
        new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            isVideoAvailable
                ? Container(
                    height: height * 0.6,
                    width: double.infinity,
                    child: Hero(
                      tag: widget.post.id,
                      child: ytPlayer(
                        videoId,
                      ),
                    ),
                  )
                : Container(
                    height: height * 0.6,
                    child: Hero(
                      tag: widget.post.id,
                      child: customImage(
                        "${currentMedia.url}&auto=compress&codec=mozjpeg&cs=strip&w=$width&fit=max",
                        double.infinity,
                      ),
                    ),
                  ),
          ],
        ),
        Positioned(
          left: 20,
          top: MediaQuery.of(context).size.height * 0.3,
          child: InkWell(
            onTap: () {
              setState(() {
                if (visiblePhotoIndex != 0) visiblePhotoIndex -= 1;
              });
            },
            child: Container(
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).highlightColor,
                size: 20,
              ),
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: <Color>[
                    Colors.white.withAlpha(0),
                    Colors.white12,
                    Colors.white70
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: MediaQuery.of(context).size.height * 0.3,
          child: InkWell(
            onTap: () {
              setState(() {
                if (visiblePhotoIndex != widget.post.media.length - 1)
                  visiblePhotoIndex += 1;
              });
            },
            child: Container(
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Theme.of(context).highlightColor,
              ),
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: <Color>[
                    Colors.white.withAlpha(0),
                    Colors.white12,
                    Colors.white70
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
