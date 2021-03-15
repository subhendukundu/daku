import 'package:flutter/material.dart';

import 'custom_dialog.dart';

class CustomThumbnail extends StatefulWidget {
  final String videoId;

  CustomThumbnail({
    this.videoId,
  });

  @override
  _CustomThumbnailState createState() => _CustomThumbnailState();
}

class _CustomThumbnailState extends State<CustomThumbnail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size?.height;
    return Container(
      height: height * 0.3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              'https://img.youtube.com/vi/${widget.videoId}/0.jpg'),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Center(
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(
                  videoId: widget.videoId,
                );
              },
            );
          },
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 100.0,
          ),
        ),
      ),
    );
  }
}
