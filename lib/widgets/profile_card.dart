import 'package:daku/models/post.dart';
import 'package:flutter/material.dart';

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
  Widget _buildBackground() {
    return new PhotoBrowser(
      photoAssetPaths: widget.post.node.media,
      visiblePhotoIndex: 0,
    );
  }

  double getTitleSize() {
    double width = MediaQuery.of(context).size?.width;
    return width > 500 ? 24 : 18;
  }

  double getDescriptionSize() {
    double width = MediaQuery.of(context).size?.width;
    return width > 500 ? 18 : 12;
  }

  int getMaxLines() {
    double height = MediaQuery.of(context).size?.height;
    return height > 600 ? 6 : 4;
  }

  Widget _buildProfileSynopsis() {
    return new Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: new Container(
        decoration: new BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Color.fromRGBO(0, 0, 0, 0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(
                    widget.post.node.name,
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: getTitleSize(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  new Text(
                    widget.post.node.description,
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: getDescriptionSize(),
                    ),
                    maxLines: getMaxLines(),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            new Image.asset(
              "assets/images/product-hunt-logo-orange-240.png",
              width: 30,
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
          boxShadow: [
            new BoxShadow(
              color: const Color(0x11000000),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            )
          ]),
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(10.0),
        child: new Material(
          child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildBackground(),
              _buildProfileSynopsis(),
            ],
          ),
        ),
      ),
    );
  }
}
