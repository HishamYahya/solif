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
import 'package:solif/screens/MainPage.dart';

void main() async {
  // lock screen rotation

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await UserAuthentication
      .loadInUser(); // only allow the user to use the app if logged in.



  EmailManualHandler emailOptions = EmailManualHandler(
      ['mohammad-x-@hotmail.com'],
      enableDeviceParameters: true,
      enableStackTrace: true,
      enableCustomParameters: true,
      enableApplicationParameters: true,
      sendHtml: true,
      emailTitle: "Sample Title",
      emailHeader: "Sample Header",
      printLogs: true);

        CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [emailOptions]);
  CatcherOptions releaseOptions =
      CatcherOptions(DialogReportMode(), [emailOptions]);

  Catcher(MyApp(), debugConfig: debugOptions, releaseConfig: releaseOptions);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppData>(
      create: (context) => AppData(),
      child: MaterialApp(
        navigatorKey: Catcher.navigatorKey,
        home: MainPage(),
      ),
    );
  }
}
