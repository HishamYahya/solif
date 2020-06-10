import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/ChatScreen.dart';

// Same as PublicChatsScreen but with different title for now
class MyChatsScreen extends StatelessWidget {
  final Future<List<SalfhTile>> salfhTiles;

  const MyChatsScreen({this.salfhTiles});



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("MY CHATS"),
          Expanded(
            child: FutureBuilder<List<SalfhTile>>(
              future: salfhTiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LoadingWidget();
                }
                if (snapshot.hasError) {
                  return Text("Error");
                }
                List<SalfhTile> swalf = snapshot.data;
                return ListView.builder(
                  itemCount: swalf.length,
                  itemBuilder: (context, index) {
                    return swalf[index];
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}






