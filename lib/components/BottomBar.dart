import 'package:flutter/material.dart';

class BottomBarItem {
  String title;
  IconData icon;

  BottomBarItem({this.title, this.icon});
}

class BottomBar extends StatefulWidget {
  final ValueChanged<int> onTap;
  final List<BottomBarItem> items;
  final String centerText;

  BottomBar({this.onTap, this.items, this.centerText});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (index) {
      return buildItem(
          item: widget.items[index], index: index, onPress: updateIndex);
    });

    // adds title under FAB (in the middle of the list)
    items.insert(widget.items.length >> 1, buildMiddleItem());

    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 5,
      child: Padding(
        padding: EdgeInsets.only(top: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: items,
        ),
      ),
    );
  }

  void updateIndex(int index) {
    widget.onTap(index);
    setState(() {
      selectedIndex = index;
    });
  }

  Widget buildItem({BottomBarItem item, int index, ValueChanged<int> onPress}) {
    Color color = selectedIndex == index ? Colors.blue : Colors.grey;

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () => onPress(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                item.icon,
                color: color,
              ),
              Text(
                item.title,
                style: TextStyle(color: color),
              )
            ],
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
            SizedBox(height: 24),
            Text(
              widget.centerText ?? '',
              style: TextStyle(color: Colors.blueAccent, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
