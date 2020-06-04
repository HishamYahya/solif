import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solif/screens/MainPage.dart';

void main() {
  // lock screen rotation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}
