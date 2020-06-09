import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solif/components/BottomBar.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/MyChatsScreen.dart';
import 'package:solif/screens/PublicChatsScreen.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int curPageIndex = 0;
  bool isAdding = false;
  AnimationController _animationController;
  Animation _rotateAnimation;
  Animation whiteToBlueAnimation;
  Animation blueToWhiteAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    // rotate 45 degrees
    _rotateAnimation =
        Tween<double>(begin: 0, end: 0.25 * pi).animate(_animationController);

    whiteToBlueAnimation = ColorTween(begin: Colors.white, end: Colors.blue)
        .animate(_animationController);

    blueToWhiteAnimation = ColorTween(begin: Colors.blue, end: Colors.white)
        .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        floatingActionButton: AnimatedBuilder(
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
                  color: whiteToBlueAnimation.value,
                ),
              ),
            );
          },
          child: null,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // custom widget
        bottomNavigationBar: BottomBar(
          centerText: "افتح سالفة",
          isAdding: isAdding,
          onTap: (value) {
            setState(() {
              curPageIndex = value;
              isAdding = false;
              _animationController.reverse();
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
        // close the add popup when dragging down
        body: GestureDetector(
          onVerticalDragDown: (details) {
            // setState(() {
            //   isAdding = false;
            // });
            // if (isAdding) {
            //   _animationController.forward();
            // } else {
            //   _animationController.reverse();
            // }
          },
          child: curPageIndex == 0 ? MyChatsScreen() : PublicChatsScreen(),
        ),
      ),
    );
  }

  // test method to generate 20 random tiles

}
