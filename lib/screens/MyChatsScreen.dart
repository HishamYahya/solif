import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/CustomSliverAppBar.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/ChatScreen.dart';

// Same as PublicChatsScreen but with different title for now
class MyChatsScreen extends StatefulWidget {
  Future<List<SalfhTile>> salfhTiles;
  final Function onUpdate;
  final bool disabled;

  MyChatsScreen({this.salfhTiles, this.onUpdate, this.disabled});

  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CustomSliverAppBar(
          onScrollStretch: () {
            setState(() {
              print("strech scroll"); // didn't work
              widget.salfhTiles = getPublicChatScreenTiles();
              widget.onUpdate(widget.salfhTiles);
            });
          },
          title: Text(
            "سوالفي2",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        FutureBuilder<List<SalfhTile>>(
          future: widget.salfhTiles,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SliverList(
                delegate: SliverChildListDelegate(
                    List.generate(1, (index) => LoadingWidget())),
              );
            }
            if (snapshot.hasError) {
              return Text("Error");
            }
            List<SalfhTile> swalf = snapshot.data;

            return SliverList(
              delegate:
                  SliverChildListDelegate(List.generate(swalf.length, (index) {
                return swalf[index];
              })),
            );
          },
        )
      ],
    );
  }
}
