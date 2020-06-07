import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solif/components/SalfhTile.dart';

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


      List<Color> colors = [
      Color(0xff4A154B),
      Color(0xff2EBD7D),
      Color(0xffECB22E),
      Color(0xffE01E5A),
      Color(0xff36C5F0)
    ];

    Random r = Random();
    for (int i = 0; i < 20; i++) {
      tiles.add(SalfhTile(
        
        title: "title$i",
        category: "category$i",
        color: colors[r.nextInt(5)]
      ));
    }
    return tiles;
  }
}
