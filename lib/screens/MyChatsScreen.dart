import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solif/components/SalfhTile.dart';

// Same as PublicChatsScreen but with different title for now
class MyChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Text("MY CHATS"),
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
