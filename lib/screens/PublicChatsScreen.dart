import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';

class PublicChatsScreen extends StatefulWidget {

  Future<List<SalfhTile>> salfhTiles; 

  PublicChatsScreen({this.salfhTiles});

  @override
  _PublicChatsScreenState createState() => _PublicChatsScreenState();
}

class _PublicChatsScreenState extends State<PublicChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          GestureDetector(child: Text("PUBLIC CHATS"),onTap:(){

            setState(() {
              widget.salfhTiles = getPublicChatScreenTiles();
            });
            

          },),
          FutureBuilder<List<SalfhTile>>(
            future: widget.salfhTiles,
            builder: (context, snapshot) {
             if (snapshot.connectionState != ConnectionState.done) {
                  return LoadingWidget();
                }
                if (snapshot.hasError) {
                  return Text("Error");
                }
                List<SalfhTile> swalf = snapshot.data;

              return Expanded(
                child: ListView.builder(
                  itemCount: swalf.length,
                  itemBuilder: (context, index) {
                    return swalf[index];
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
