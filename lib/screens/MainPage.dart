import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/BottomBar.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/screens/MyChatsScreen.dart';
import 'package:solif/screens/PublicChatsScreen.dart';

class MainPage extends StatefulWidget {
  Future<List<SalfhTile>> usersSalfhTiles = getUsersChatScreenTiles("00user");
  Future<List<SalfhTile>> publicSalfhTiles = getPublicChatScreenTiles();

  
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
  TabController _tabController; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2);

    _tabController.addListener(() {
      if (_tabController.index != curPageIndex) {
        setState(() {
          curPageIndex = _tabController.index;
        });
      }
    });

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _animationController.dispose();

    _tabController.dispose();
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
          selectedIndex: curPageIndex,
          onTap: (value) {
            if (curPageIndex != value) {
              setState(() {
                curPageIndex = value;
                _tabController.animateTo(value);
                isAdding = false;
                _animationController.reverse();
              });
            }
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
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              MyChatsScreen(
                disabled: isAdding,
                  salfhTiles: widget.usersSalfhTiles,
                  onUpdate: (Future<List<SalfhTile>> updatedUserSwalf){
                    widget.usersSalfhTiles = updatedUserSwalf;
                  },
                ),
              PublicChatsScreen(
                  disabled: isAdding,
                  salfhTiles: widget.publicSalfhTiles,
                  onUpdate: (Future<List<SalfhTile>> updatedPublicSwalf) {
                    widget.publicSalfhTiles = updatedPublicSwalf;
                  }
                )
            ],
          ),
        ),
      ),
    );
  }

  // test method to generate 20 random tiles

}
