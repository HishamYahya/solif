import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solif/components/NavigationButton.dart';
import 'package:solif/components/SalfhTile.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: getSalfhTiles(),
              ),
            ),
            Container(
              color: Colors.blueGrey,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  NavigationButton(title: "11"),
                  NavigationButton(title: "2"),
                  NavigationButton(title: "3"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  // test method to generate 20 random tiles
  List<SalfhTile> getSalfhTiles() { 
    List<SalfhTile> tiles = List<SalfhTile>();

    for (int i = 0; i < 20; i++) {
      tiles.add(SalfhTile(
        title: "title$i",
        category: "category$i",
        color: Colors.primaries[
            Random().nextInt(Colors.primaries.length)], // random color;
      ));
    }
    return tiles;
  }
}


