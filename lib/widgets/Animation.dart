import 'dart:async';

import 'package:daku/SavedPosts/DetailedPage.dart';
import 'package:flutter/material.dart';

class SlideFadeTransition extends StatefulWidget {
  final Widget child;

  final double offset;

  final Curve curve;

  final Direction direction;

  final Duration delayStart;

  final Duration animationDuration;

  SlideFadeTransition({
    @required this.child,
    this.offset = 1.0,
    this.curve = Curves.easeIn,
    this.direction = Direction.vertical,
    this.delayStart = const Duration(seconds: 0),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  _SlideFadeTransitionState createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition>
    with SingleTickerProviderStateMixin {
  Animation<Offset> _animationSlide;

  AnimationController _animationController;

  Animation<double> _animationFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.direction == Direction.vertical) {
      _animationSlide = Tween<Offset>(
        begin: Offset(0, widget.offset),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
          curve: widget.curve,
          parent: _animationController,
        ),
      );
    } else {
      _animationSlide = Tween<Offset>(
        begin: Offset(widget.offset, 0),
        end: Offset(0, 0),
      ).animate(
        CurvedAnimation(
          curve: widget.curve,
          parent: _animationController,
        ),
      );
    }

    _animationFade = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        curve: widget.curve,
        parent: _animationController,
      ),
    );

    Timer(
      widget.delayStart,
      () {
        _animationController.forward();
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationFade,
      child: SlideTransition(
        position: _animationSlide,
        child: widget.child,
      ),
    );
  }
}
