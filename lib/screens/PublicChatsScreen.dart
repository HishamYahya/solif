import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/CustomSliverAppBar.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';

class PublicChatsScreen extends StatefulWidget {
  Future<List<SalfhTile>> salfhTiles = getPublicChatScreenTiles();
  final Function onUpdate;
  final bool disabled;

  PublicChatsScreen({this.salfhTiles, this.onUpdate, this.disabled,th});

  @override
  _PublicChatsScreenState createState() => _PublicChatsScreenState();
}

class _PublicChatsScreenState extends State<PublicChatsScreen> {
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
        FutureBuilder<List<SalfhTile>>(
          future: widget.salfhTiles,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SliverList(delegate: SliverChildListDelegate(
                List.generate(1, (index) => LoadingWidget())
              ),);
            }
            if (snapshot.hasError) {
              return Text("Error");
            }
            List<SalfhTile> swalf = snapshot.data;

            return SliverList(delegate: SliverChildListDelegate(
              List.generate(swalf.length, (index) {
                return swalf[index];
              })
            ),);
          },
        )
      ],
    );
  }
}



