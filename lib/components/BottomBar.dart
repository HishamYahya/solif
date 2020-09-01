import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:solif/screens/AddScreen.dart';

import '../constants.dart';

class BottomBarItem {
  String title;
  IconData icon;

  BottomBarItem({this.title, this.icon});
}

class BottomBar extends StatefulWidget {
  final ValueChanged<int> onTap;
  final Function onClose;
  final List<BottomBarItem> items;
  final String centerText;
  final bool isAdding;
  final int selectedIndex;

  BottomBar(
      {this.onTap,
      this.onClose,
      this.items,
      this.centerText,
      this.isAdding,
      this.selectedIndex});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation whiteToBlueAnimation;
  Animation blueToWhiteAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 200),
    );
    whiteToBlueAnimation =
        ColorTween(begin: Colors.white, end: kMainColor).animate(controller)
          ..addListener(() {
            setState(() {});
          });
    blueToWhiteAnimation =
        ColorTween(begin: kMainColor, end: Colors.white).animate(controller);
  }

  @override
  void didUpdateWidget(BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAdding & !oldWidget.isAdding) {
      controller.forward();
    }
    if (!widget.isAdding & oldWidget.isAdding) {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (index) {
      return buildItem(
          item: widget.items[index], index: index, onPress: updateIndex);
    });
    // adds title under FAB (in the middle of the list)
    items.insert(widget.items.length >> 1, buildMiddleItem());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 5,
          color: whiteToBlueAnimation.value,
          child: Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: items,
              ),
            ),
          ),
        ),
        AddScreen(isAdding: widget.isAdding, onClose: widget.onClose),
      ],
    );
  }

  void updateIndex(int index) {
    widget.onTap(index);
  }

  Widget buildItem({BottomBarItem item, int index, ValueChanged<int> onPress}) {
    Color color = widget.selectedIndex == index
        ? blueToWhiteAnimation.value
        : Colors.grey[400];

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            onPress(index);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              item.icon,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMiddleItem() {
    return Expanded(
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 26),
            AutoSizeText(
              widget.centerText ?? '',
              maxLines: 1,
              style: TextStyle(color: blueToWhiteAnimation.value, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
