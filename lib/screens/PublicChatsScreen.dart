import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';

class PublicChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Text("PUBLIC CHATS"),
          Expanded(
            child: ListView(
              children: getSalfhTiles(),
            ),
          ),
        ],
      ),
    );
  }


  List<SalfhTile> getSalfhTiles() {
    List<SalfhTile> tiles = List<SalfhTile>();

    Random r = Random();
    for (int i = 0; i < 20; i++) {
      tiles.add(SalfhTile(
        
        title: "title$i",
        category: "category$i",
        color: kColorNames[r.nextInt(5)]
        // 
      ));
    }
    return tiles;
  }
}
