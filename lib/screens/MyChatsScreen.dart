import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/ChatScreen.dart';

// Same as PublicChatsScreen but with different title for now
class MyChatsScreen extends StatefulWidget {
  Future<List<SalfhTile>> salfhTiles;
  final Function onUpdate;

  MyChatsScreen({this.salfhTiles,this.onUpdate});

  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(child: Text("MY CHATS"),onTap: (){
                  setState(() {
                widget.salfhTiles = getUsersChatScreenTiles("00user");
                widget.onUpdate(widget.salfhTiles);
              });
            
          }),
          Expanded(
            child: FutureBuilder<List<SalfhTile>>(
              future: widget.salfhTiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return LoadingWidget();
                }
                if (snapshot.hasError) {
                  return Text("Error");
                }
                List<SalfhTile> swalf = snapshot.data;
                
                print("length here${swalf.length}");
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






