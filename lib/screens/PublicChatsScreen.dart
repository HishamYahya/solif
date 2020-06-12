import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/CustomSliverAppBar.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';

class PublicChatsScreen extends StatefulWidget {
  final bool disabled;

  PublicChatsScreen({this.disabled});

  @override
  _PublicChatsScreenState createState() => _PublicChatsScreenState();
}

class _PublicChatsScreenState extends State<PublicChatsScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    List<SalfhTile> salfhTiles = await getPublicChatScreenTiles();
    if (salfhTiles == null) {
      //TODO: Display error
      _refreshController.refreshFailed();
    } else {
      Provider.of<AppData>(context, listen: false)
          .setPublicSalfhTiles(salfhTiles);
    }
    _refreshController.refreshFailed();
  }

  void onLoading() async {
    //TODO: Load more data when scrolling up at the end
    _refreshController.loadNoData();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoaded = Provider.of<AppData>(context).isPublicTilesLoaded();
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: onLoading,
      enablePullUp: true,
      header: WaterDropMaterialHeader(
        offset: 55,
        distance: 40,
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          CustomSliverAppBar(
            title: Text(
              "سواليفهم",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              isLoaded
                  ? Provider.of<AppData>(context).publicSalfhTiles
                  : [LoadingWidget('...نجيب سوالفهم')],
            ),
          ),
        ],
      ),
    );
  }
}
