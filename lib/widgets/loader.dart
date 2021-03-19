import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class Loader extends StatefulWidget {
  const Loader({Key key}) : super(key: key);

  @override
  _LoaderState createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  Artboard _riveArtboard;
  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  void _loadRiveFile() async {
    final bytes = await rootBundle.load('assets/riv/logo.riv');
    final file = RiveFile();
    if (file.import(bytes)) {
      setState(() => _riveArtboard = file.mainArtboard
        ..addController(SimpleAnimation('start')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _riveArtboard == null
            ? const SizedBox()
            : Rive(
                artboard: _riveArtboard,
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
              ),
      ),
    );
  }
}
