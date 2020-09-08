import 'package:catcher/core/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/handlers/email_manual_handler.dart';
import 'package:catcher/mode/dialog_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/UserAuthentication.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/MainPage.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  // lock screen rotation

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await UserAuthentication
      .loadInUser(); // only allow the user to use the app if logged in.

  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>(
          create: (context) => AppData(),
        ),
        ChangeNotifierProvider<Preferences>(
          create: (context) => Preferences(),
        )
      ],
      child: MaterialApp(
        navigatorKey: Catcher.navigatorKey,
        home: MainPage(),
      ),
    );
  }
}
