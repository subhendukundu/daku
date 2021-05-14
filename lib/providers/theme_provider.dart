// we use provider to manage the app state

import 'package:daku/configs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  bool isLightTheme;
  BuildContext context;

  ThemeProvider({
    this.isLightTheme,
    this.context,
  });

  getCurrentStatusNavigationBarColor() {
    if (isLightTheme) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF26242e),
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  toggleThemeData() async {
    final settings = await Hive.openBox('settings');
    settings.put('isLightTheme', !isLightTheme);
    isLightTheme = !isLightTheme;
    getCurrentStatusNavigationBarColor();
    notifyListeners();
  }

  ThemeData themeData() {
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: isLightTheme ? Colors.grey : Colors.grey,
      primaryColor: isLightTheme ? Color(0xFFE2E3E3) : Color(0xFF101319),
      highlightColor: isLightTheme ? Color(0xFF080808) : Color(0xFFE3E3E3),
      indicatorColor: isLightTheme ? Color(0xFF8C8C8C) : Color(0xFF3C3C3C),
      brightness: isLightTheme ? Brightness.light : Brightness.dark,
      backgroundColor: isLightTheme ? Color(0xFFE2E3E3) : Color(0xFF101319),
      scaffoldBackgroundColor:
          isLightTheme ? Color(0xFFE2E3E3) : Color(0xFF101319),
      cardColor: isLightTheme ? Color(0xFFE4E4E5) : Color(0xFF1C2025),
      hintColor: isLightTheme ? border.shade50 : border.shade500,
      textTheme: TextTheme(
        headline1: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: isLightTheme ? Color(0xFF080808) : Color(0xFFE3E3E3),
        ),
        subtitle1: GoogleFonts.lato(
          fontWeight: FontWeight.w400,
          color: isLightTheme ? Color(0xFF191919) : Color(0xFFBABABA),
        ),
      ),
    );
  }

  ThemeColor themeMode() {
    return ThemeColor(
      gradient: [
        if (isLightTheme) ...[Color(0xDDFF0080), Color(0xDDFF8C00)],
        if (!isLightTheme) ...[Color(0xFF8983F7), Color(0xFFA3DAFB)]
      ],
      textColor: isLightTheme ? Color(0xFF000000) : Color(0xFFFFFFFF),
      toggleButtonColor: isLightTheme ? Color(0xFFFFFFFF) : Color(0xFf34323d),
      toggleBackgroundColor:
          isLightTheme ? Color(0xFFe7e7e8) : Color(0xFF222029),
      shadow: [
        if (isLightTheme)
          BoxShadow(
            color: Color(0xFFd8d7da),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        if (!isLightTheme)
          BoxShadow(
            color: Color(0x66000000),
            spreadRadius: 5,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
      ],
    );
  }
}

// A class to manage specify colors and styles in the app not supported by theme data
class ThemeColor {
  List<Color> gradient;
  Color backgroundColor;
  Color toggleButtonColor;
  Color toggleBackgroundColor;
  Color textColor;
  List<BoxShadow> shadow;

  ThemeColor({
    this.gradient,
    this.backgroundColor,
    this.toggleBackgroundColor,
    this.toggleButtonColor,
    this.textColor,
    this.shadow,
  });
}

// Provider finished
