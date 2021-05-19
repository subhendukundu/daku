import 'package:daku/models/post.dart';
import 'package:daku/saved_posts/detailed_page.dart';
import 'package:daku/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Cards extends StatefulWidget {
  final List<Node> posts;
  final OnProgress onProgress;

  Cards({Key key, this.onProgress, this.posts}) : super(key: key);

  @override
  _CardsState createState() => _CardsState();
}

class _CardsState extends State<Cards> with TickerProviderStateMixin {
  List<Tween<double>> rotationTween = [];
  List<Tween<double>> offsetTweens = [];
  List<Tween<double>> sizeOffsetTweens = [];
  List<Tween<double>> opacityTweens = [];

  AnimationController _swipeController;
  AnimationController _backController;

  int position = 0;
  Direction direction = Direction.NONE;

  @override
  void initState() {
    _swipeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    )
      ..addListener(() {
        setState(() {
          final curve = CurvedAnimation(
              parent: _swipeController, curve: Curves.fastOutSlowIn);
          for (var i = 0; i < widget.posts.length - position; ++i) {
            widget.posts[position + i].offset = offsetTweens[i].evaluate(curve);
            widget.posts[position + i].rotation =
                rotationTween[i].evaluate(curve);

            widget.posts[position + i].sizeOffset =
                sizeOffsetTweens[i].evaluate(curve);
            widget.posts[position + i].opacity =
                opacityTweens[i].evaluate(curve);

            if (i == position) {
              widget.onProgress(
                  _calculateProgress(widget.posts[i].offset), Direction.AWAY);
            }
          }
        });
      })
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            position += 1;
            widget.onProgress(100, Direction.NONE);
            direction = Direction.NONE;
          }
        },
      );

    _backController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250))
          ..addListener(() {
            setState(() {
              final curve = CurvedAnimation(
                  parent: _backController, curve: Curves.fastOutSlowIn);
              for (var i = 0; i < widget.posts.length - position; ++i) {
                widget.posts[position + i].offset =
                    offsetTweens[i].evaluate(curve);
                widget.posts[position + i].rotation =
                    rotationTween[i].evaluate(curve);

                widget.posts[position + i].sizeOffset =
                    sizeOffsetTweens[i].evaluate(curve);
                widget.posts[position + i].opacity =
                    opacityTweens[i].evaluate(curve);

                if (i == position) {
                  widget.onProgress(
                      100 - _calculateProgress(widget.posts[i].offset),
                      Direction.BACK);
                }
              }
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.onProgress(100, Direction.NONE);
              direction = Direction.NONE;
            }
          });
    super.initState();
    onStart();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        // ignore: deprecated_member_use
        overflow: Overflow.clip,
        // fit: StackFit.loose,
        alignment: Alignment.centerLeft,
        children: _buildStack(),
      ),
    );
  }

  onStart() {
    _onDragEnd(DragEndDetails());
  }

  List<Widget> _buildStack() {
    return widget.posts
        .map((model) {
          if (kIsWeb) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TransPageView(post: widget.posts[position]);
                    },
                  ),
                );
              },
              child: Center(
                child: EventCard(
                  post: model,
                  opacity: model.opacity,
                  offset: model.offset,
                  sizeOffset: model.sizeOffset,
                  rotation: model.rotation,
                ),
              ),
            );
          } else {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return TransPageView(post: widget.posts[position]);
                    },
                  ),
                );
              },
              child: EventCard(
                post: model,
                opacity: model.opacity,
                offset: model.offset,
                sizeOffset: model.sizeOffset,
                rotation: model.rotation,
              ),
            );
          }
        })
        .toList()
        .reversed
        .toList();
  }

  // _onDragStart(DragStartDetails details) {}

  _onDragUpdate(DragUpdateDetails details) {
    if (direction == Direction.NONE) {
      if (details.delta.dx > 0) {
        direction = Direction.BACK;
        if (position != 0) {
          position -= 1;
        }
      } else {
        direction = Direction.AWAY;
      }
    }

    setState(() {
      for (var i = position; i < widget.posts.length; ++i) {
        final model = widget.posts[i];

        if (i == position) {
          model.opacity = 1.0;
          model.offset += details.delta.dx;

          model.sizeOffset -= details.delta.dx / 12;

          var progress = _calculateProgress(model.offset);
          if (direction == Direction.BACK) {
            progress = 100 - progress;
            model.rotation += details.delta.dx * 0.0005;
          }
          if (direction == Direction.AWAY) {
            model.rotation -= details.delta.dx * 0.0005;
          }

          widget.onProgress(progress, direction);
          continue;
        }

        final distance = details.delta.dx / (i * 6);
        model.offset += distance;
        model.sizeOffset = (model.sizeOffset + distance).clamp(0.0, 400.0);

        final targetOpacity = 0.3 * i;
        final targetOffset = 70 * i;

        model.opacity = 1 - (targetOpacity * model.offset / targetOffset);
      }
    });
  }

  _onDragEnd(DragEndDetails details) {
    offsetTweens.clear();
    sizeOffsetTweens.clear();
    opacityTweens.clear();
    rotationTween.clear();

    if (direction == Direction.AWAY && position != widget.posts.length - 1) {
      for (var i = position; i < widget.posts.length; ++i) {
        rotationTween.add(
          Tween(
            begin: widget.posts[i].rotation,
            end: i == position ? 0.05 : 0.0 * (i - position - 1),
          ),
        );
        offsetTweens.add(
          Tween(
            begin: widget.posts[i].offset,
            end: i == position
                ? -360.0
                : i >= position + 4
                    ? 80
                    : 80.0 * (i - position - 1),
          ),
        );
        sizeOffsetTweens.add(
          Tween(
            begin: widget.posts[i].sizeOffset,
            end: i == position
                ? 0
                : i >= position + 4
                    ? 80
                    : 40.0 * (i - position - 1),
          ),
        );
        opacityTweens.add(
          Tween(
            begin: widget.posts[i].opacity,
            end: i == position
                ? 0.0
                : i >= position + 3
                    ? 0.4
                    : 1 - (0.3 * (i - position - 1)),
          ),
        );
      }
      _swipeController.forward(from: 0.0);
    } else {
      for (var i = position; i < widget.posts.length; ++i) {
        rotationTween.add(
          Tween(
            begin: widget.posts[i].rotation,
            end: 0.0 * (i - position - 1),
          ),
        );
        offsetTweens.add(
          Tween(
            begin: widget.posts[i].offset,
            end: i >= position + 3 ? 80 : 70.0 * (i - position),
          ),
        );
        sizeOffsetTweens.add(
          Tween(
            begin: widget.posts[i].sizeOffset,
            end: i >= position + 3 ? 80 : 40.0 * (i - position),
          ),
        );
        opacityTweens.add(
          Tween(
            begin: widget.posts[i].opacity,
            end: i >= position + 3 ? 0 : 1 - (0.3 * (i - position)),
          ),
        );
      }
      _backController.forward(from: 0.0);
    }
  }

  /// from 40 to -280
  /// means 40 is 0 and -280 is 100
  int _calculateProgress(double offset) {
    final positiveOffset = offset + 280;
    return 100 - (100 * positiveOffset ~/ 320);
  }

  @override
  void reassemble() {
    position = 0;
    direction = Direction.NONE;

    super.reassemble();
  }
}

class EventCard extends StatelessWidget {
  final Node post;
  final bool interested;

  final double opacity;
  final double offset;
  final double sizeOffset;
  final double rotation;

  EventCard({
    Key key,
    this.post,
    this.interested,
    this.offset = 0.0,
    this.opacity = 0.0,
    this.rotation = 0.0,
    this.sizeOffset = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Post postData = Post();
    postData.node = post;

    final Size size = Size(MediaQuery.of(context).size.width * 0.7,
        MediaQuery.of(context).size.height * 0.65);

    return Transform.translate(
      offset: Offset(30 + offset, sizeOffset / 12),
      child: Transform.rotate(
        angle: -rotation,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size.width - sizeOffset,
            height: size.height - sizeOffset,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Card(
                color: Theme.of(context).primaryColor,
                child: ProfileCard(
                  post: postData,
                  forSavedCard: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getTitleSize(context) {
    double width = MediaQuery.of(context).size?.width;
    if (width > 500) {
      return 24;
    } else if (width > 350) {
      return width * 0.05;
    } else {
      return width * 0.04;
    }
  }
}

enum Direction { AWAY, BACK, NONE }

typedef OnProgress = Function(int progress, Direction direction);
