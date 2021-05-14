import 'package:flutter/material.dart';

class SizeTransition1 extends PageRouteBuilder {
  final Widget page;

  SizeTransition1(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: Duration(milliseconds: 600),
          reverseTransitionDuration: Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                curve: Curves.fastOutSlowIn,
                parent: animation,
                reverseCurve: Curves.fastOutSlowIn);
            return Align(
              alignment: Alignment.bottomCenter,
              child: SizeTransition(
                sizeFactor: animation,
                child: page,
                axisAlignment: -1,
              ),
            );
          },
        );
}
