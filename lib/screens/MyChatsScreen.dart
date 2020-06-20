import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/CustomSliverAppBar.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/screens/ChatScreen.dart';

// Same as PublicChatsScreen but with different title for now
class MyChatsScreen extends StatefulWidget {
  final bool disabled;

  MyChatsScreen({this.disabled});

  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    bool isLoaded = Provider.of<AppData>(context).isUsersTilesLoaded();
    return CustomScrollView(
      slivers: <Widget>[
        CustomSliverAppBar(
          title: Text(
            "سوالفي2",
            style: TextStyle(color: kMainColor),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            isLoaded
                ? Provider.of<AppData>(context).usersSalfhTiles
                : [LoadingWidget('...نجيب سوالفك')],
          ),
        ),
      ],
    );
  }
}
