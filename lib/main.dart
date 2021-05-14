import 'package:daku/Auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:daku/root_app.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'providers/theme_provider.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  runApp(OAuthExample());
}

// void main() async {
//   GetStorage.init();

//   setPathUrlStrategy();
//   WidgetsFlutterBinding.ensureInitialized();
//   if (!kIsWeb) {
//     final dynamic appDocumentDirectory =
//         await pathProvider.getApplicationDocumentsDirectory();
//     Hive.init(appDocumentDirectory.path as String);
//   }

//   final settings = await Hive.openBox('settings');
//   bool isLightTheme = settings.get('isLightTheme') ?? false;

//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => ThemeProvider(
//         isLightTheme: isLightTheme,
//         context: context,
//       ),
//       child: AppStart(),
//     ),
//   );
// }

// class AppStart extends StatelessWidget {
//   const AppStart({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
//     return RootPage(
//       themeProvider: themeProvider,
//     );
//   }
// }
