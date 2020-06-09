import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';

class PublicChatsScreen extends StatelessWidget {
  final firestore = Firestore.instance;
  Random random = Random();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Text("PUBLIC CHATS"),

          StreamBuilder<QuerySnapshot>(
            stream: firestore.collection("Swalf").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("ok");
              }

              final salfhDocs = snapshot.data.documents;
              List<SalfhTile> salfhTiles = [];
              for (var salfh in salfhDocs) {
                salfhTiles.add(SalfhTile(
                  category: salfh["category"],
                  color: kColorNames[random
                      .nextInt(kColorNames.length)], //salfh['colorStatus'],
                  title: salfh['title'],
                  id: salfh.documentID,
                  
                ));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: salfhDocs.length,
                  itemBuilder: (context, index) {
                    return salfhTiles[index];
                  },
                ),
              );
            },
          )
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
