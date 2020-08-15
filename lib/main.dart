import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/UserAuthentication.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/screens/MainPage.dart';

void main() async{
  // lock screen rotation
  
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await UserAuthentication.loadInUser(); // only allow the user to use the app if logged in. 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppData>(
      create: (context) => AppData(),
      child: MaterialApp(
        home:  MainPage(),
      ),
    );
  }
}


