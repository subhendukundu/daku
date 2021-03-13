import 'package:flutter/material.dart';
import 'package:daku/root_app.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RootPage(),
  ));
}
