import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/Services/UserAuthentication.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/components/SliverSearchBar.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/ChatScreen.dart';
import 'package:solif/screens/SettingsScreen.dart';
import 'package:solif/screens/UserInterestScreen.dart';

// Same as PublicChatsScreen but with different title for now
class MyChatsScreen extends StatefulWidget {
  final bool disabled;

  MyChatsScreen({this.disabled});

  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  Future<List<SalfhTile>> usersChatScreenTiles;
  @override
  // to keep the page from refreshing each time you change back to it
  // (now only loaded once but always saved which might be a problem)
  // bool get wantKeepAlive => true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoaded = Provider.of<AppData>(context).isUsersTilesLoaded();
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(
            isLoaded
                ? Provider.of<AppData>(context).usersSalfhTiles.isEmpty
                    ? [
                        Container(
                          height: 200,
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text(
                              isArabic
                                  ? "ما دخلت سالفة لسا\n !افتح او خش وحدة وسولف"
                                  : "You haven't joined any chats yet, open one!",
                              style: TextStyle(
                                color: darkMode
                                    ? kDarkModeTextColor60
                                    : Colors.grey[500],
                                fontSize: 30,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ]
                    : Provider.of<AppData>(context).usersSalfhTiles
                : [LoadingWidget('...نجيب سوالفك')],
          ),
        ),
      ],
    );
  }
}
