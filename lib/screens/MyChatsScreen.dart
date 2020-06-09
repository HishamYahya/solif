import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/ChatScreen.dart';

// Same as PublicChatsScreen but with different title for now
class MyChatsScreen extends StatefulWidget {
  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  Future<List<SalfhTile>> salfhTiles;

  @override
  void initState() {
    super.initState();
    String userID = '00user';
    print("here");
    salfhTiles = getSalfhTilesIthink(userID);
  }

  @override
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          Text("MY CHATS"),
          Expanded(
            child: FutureBuilder<List<SalfhTile>>(
              future: salfhTiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text("loading");
                }
                if (snapshot.hasError) {
                  return Text("Error");
                }
                List<SalfhTile> swalf = snapshot.data ?? [];

                if(swalf.length == 0){
                  return Text("loading");
                }
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

Future<List<SalfhTile>> getSalfhTiles(String userID) async {
  final firestore = Firestore.instance;

  final salfhDoc = await firestore.collection('users').document(userID).get();
  List<SalfhTile> salfhTiles = [];
  Map<String, dynamic> userSwalf = salfhDoc['userSwalf'];
  userSwalf.forEach((salfhID, userColor) async {
    var currentSalfh =
        await firestore.collection('Swalf').document(salfhID).get();

    salfhTiles.add(SalfhTile(
      category: currentSalfh["category"],
      color: userColor,
      title: currentSalfh['title'], 
      id: currentSalfh.documentID,
    ));
  });
  return salfhTiles;
}

Future<List<SalfhTile>> getSalfhTilesIthink(String userID) async {
  List<SalfhTile> result = [];
  result = await getSalfhTiles(userID);
  return result;
}