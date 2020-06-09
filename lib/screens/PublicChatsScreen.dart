import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solif/components/CustomSliverAppBar.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';

class PublicChatsScreen extends StatelessWidget {
  final bool disabled;

  PublicChatsScreen(this.disabled);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CustomSliverAppBar(
          title: Text(
            "سواليفهم",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(getSalfhTiles()),
        )
      ],
    );
  }

  List<SalfhTile> getSalfhTiles() {
    List<SalfhTile> tiles = List<SalfhTile>();

    Random r = Random();
    for (int i = 0; i < 20; i++) {
      tiles.add(SalfhTile(
          disabled: disabled,
          title: "title$i",
          category: "category$i",
          color: kColorNames[r.nextInt(5)]
          //
          ));
    }
    return tiles;
  }
}
