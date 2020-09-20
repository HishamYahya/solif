import 'package:catcher/core/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/handlers/email_manual_handler.dart';
import 'package:catcher/mode/dialog_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/UserAuthentication.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/CurrentOpenChat.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/MainPage.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  // lock screen rotation

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // await UserAuthentication
  //     .loadInUser(); // only allow the user to use the app if logged in. //TODO: call plugins that rely on firebase after initilization.

  // Crashlytics.instance.enableInDevMode = true;

  // // Pass all uncaught errors from the framework to Crashlytics.
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;//TODO: call plugins that rely on firebase after initilization.

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RunApp();
          } else if (snapshot.hasError) {
            print('error with initializating firebase');
            return MaterialApp(
              home: OurErrorWidget(
                  errorMessage: "error with initializating firebase"),
            );
          } else {
            print('loading firebase');
            return MaterialApp(
              home: Text(
                'loading firebase',
                textDirection: TextDirection.ltr,
              ),
            );
          }
        });
  }
}

class RunApp extends StatelessWidget {
  const RunApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppData>(
          create: (context) => AppData(),
        ),
        ChangeNotifierProvider<Preferences>(
          create: (context) => Preferences(),
        ),
        ChangeNotifierProvider<CurrentOpenChat>(
          create: (context) => CurrentOpenChat(),
        )
      ],
      child: OverlaySupport(
        child: MaterialApp(
          navigatorKey: Catcher.navigatorKey,
          home: MainPage(),
        ),
      ),
    );
  }
}
