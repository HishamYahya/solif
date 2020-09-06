import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/BottomBar.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/MyChatsScreen.dart';
import 'package:solif/screens/NotificationsScreen.dart';
import 'package:solif/screens/PublicChatsScreen.dart';
import 'package:solif/Services/FCM.dart';
import 'package:solif/screens/SettingsScreen.dart';

import '../constants.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int curPageIndex = 0;
  bool isAdding = false;
  AnimationController _animationController;
  Animation _rotateAnimation;
  Animation whiteToBlueAnimation;
  Animation blueToWhiteAnimation;

  final fcm = FirebaseMessaging();

  static Future<dynamic> backgroundMessageHandler(
      Map<String, dynamic> message) async {
    // if (message.containsKey('data')) {
    //   // Handle data message
    //   final dynamic data = message['data'];

    //   if (data['type'] == 'inv') {
    //     var prefs = await SharedPreferences.getInstance();
    //     List<String> invitedToSwalf =
    //         prefs.getStringList('invited') ?? List<String>();

    //     invitedToSwalf.add(data['id']);

    //     prefs.setStringList('invited', invitedToSwalf);
    //   }
    // }

    // if (message.containsKey('notification')) {
    //   // Handle notification message
    //   final dynamic notification = message['notification'];
    // }
    print('RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAN');
    print(message);
    return null;
    // Or do other work.
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fcm.configure(
      onLaunch: (message) {
        print("onLaunch $message");
      },
      onResume: (message) {
        print("onResume $message");
      },
      onMessage: (message) {
        print("onMessage $message");
        //  foregroundMessageHandler(message);
      },
      onBackgroundMessage: backgroundMessageHandler,
    );

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    // rotate 45 degrees
    _rotateAnimation =
        Tween<double>(begin: 0, end: 0.25 * pi).animate(_animationController);

    whiteToBlueAnimation = ColorTween(begin: Colors.white, end: kMainColor)
        .animate(_animationController);

    blueToWhiteAnimation = ColorTween(begin: kMainColor, end: Colors.white)
        .animate(_animationController);

    Provider.of<Preferences>(context, listen: false).addListener(() {
      bool darkMode = Provider.of<Preferences>(context, listen: false).darkMode;
      whiteToBlueAnimation = ColorTween(
              begin: darkMode ? Color(0XFF121212) : Colors.white,
              end: kMainColor)
          .animate(_animationController);

      blueToWhiteAnimation = ColorTween(
        begin: kMainColor,
        end: darkMode ? Color(0XFF121212) : Colors.white,
      ).animate(_animationController);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _animationController.dispose();
  }

  String _getAppBarTitle() {
    switch (curPageIndex) {
      case 0:
        return 'سواليفي';
      case 1:
        return 'سواليفهم';
      case 2:
        return 'التنبيهات';
      case 3:
        return 'شخصي';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    print(darkMode);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkMode ? Color(0XFF121212) : Colors.white,
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            color: darkMode ? kDarkModeTextColor87 : Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Tooltip(
            message: 'نقاطك',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '1750',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ),
                  Image.asset(
                    'images/dots.png',
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
        leading: curPageIndex == 2
            ? Icon(Icons.notifications, color: Colors.grey[500])
            : null,
        centerTitle: true,
      ),
      backgroundColor: darkMode ? Colors.black : Colors.grey[100],
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0 ||
              isAdding
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // rotate the button 45 degrees
                return Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: FloatingActionButton(
                    backgroundColor: blueToWhiteAnimation.value,
                    elevation: 2.0,
                    onPressed: () {
                      setState(() {
                        isAdding = !isAdding;
                      });

                      // alternate icon between x and +
                      if (isAdding) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    },
                    child: Icon(
                      Icons.add,
                      color:
                          darkMode ? Colors.white : whiteToBlueAnimation.value,
                    ),
                  ),
                );
              },
              child: null,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // custom widget
      bottomNavigationBar: SingleChildScrollView(
        child: BottomBar(
          centerText: "افتح سالفة",
          isAdding: isAdding,
          selectedIndex: curPageIndex,
          onTap: (value) {
            if (curPageIndex != value) {
              setState(() {
                curPageIndex = value;
                isAdding = false;
                _animationController.reverse();
              });
            }
          },
          onClose: () {
            setState(() {
              isAdding = false;
              _animationController.reverse();
            });
          },
          items: [
            BottomBarItem(
              title: "",
              icon: Icons.chat_bubble_outline,
            ),
            BottomBarItem(
              title: "",
              icon: Icons.chat_bubble,
            ),
            BottomBarItem(
              title: "",
              icon: Icons.notifications,
            ),
            BottomBarItem(
              title: "",
              icon: Icons.account_circle,
            ),
          ],
        ),
      ),
      // close the add popup when dragging down`
      body: GestureDetector(
        onVerticalDragDown: (details) {
          if (isAdding) {
            setState(() {
              isAdding = false;
            });
            _animationController.reverse();
          }
        },
        onTap: () {
          if (isAdding) {
            _animationController.reverse();
            setState(() {
              isAdding = false;
            });
          }
        },
        child: IndexedStack(
          index: curPageIndex,
          children: <Widget>[
            MyChatsScreen(
              disabled: isAdding,
            ),
            PublicChatsScreen(
              disabled: isAdding,
            ),
            NotificationsScreen(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }

  // test method to generate 20 random tiles

}
