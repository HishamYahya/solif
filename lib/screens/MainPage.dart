import 'package:flutter/material.dart';
import 'package:solif/components/BottomBar.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/MyChatsScreen.dart';
import 'package:solif/screens/PublicChatsScreen.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int curPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        floatingActionButton: FloatingActionButton(
          elevation: 2.0,
          child: Icon(Icons.add),
          onPressed: () {
            //TODO: display two extra buttons when pressed
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // custom widget
        bottomNavigationBar: BottomBar(
          centerText: "افتح سالفة",
          onTap: (value) {
            setState(() {
              curPageIndex = value;
            });
          },
          items: [
            BottomBarItem(
              title: "سواليفي",
              icon: Icons.chat_bubble_outline,
            ),
            BottomBarItem(
              title: "سواليفهم",
              icon: Icons.chat_bubble,
            ),
          ],
        ),
        body: curPageIndex == 0 ? MyChatsScreen() : PublicChatsScreen(),
      ),
    );
  }

  // test method to generate 20 random tiles

}
