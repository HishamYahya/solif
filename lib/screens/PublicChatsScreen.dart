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

class _PublicChatsScreenState extends State<PublicChatsScreen>
    with AutomaticKeepAliveClientMixin<PublicChatsScreen> {
  @override
  // to keep the page from refreshing each time you change back to it
  // (now only loaded once but always saved which might be a problem)
  bool get wantKeepAlive => true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    await Provider.of<AppData>(context, listen: false).reloadPublicSalfhTiles();
    if (!mounted) return;
    List<SalfhTile> salfhTiles =
        Provider.of<AppData>(context, listen: false).publicSalfhTiles;
    if (salfhTiles == null) {
      //TODO: Display error
      _refreshController.refreshFailed();
    } else {
      Provider.of<AppData>(context, listen: false)
          .setPublicSalfhTiles(salfhTiles);
    }
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }

  void onLoading() async {
    final state = Provider.of<AppData>(context, listen: false);
    int currentLength = state.publicSalfhTiles.length;
    await state.loadNextPublicSalfhTiles();
    if (currentLength == state.publicSalfhTiles.length)
      _refreshController.loadNoData();
    else
      _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoaded = Provider.of<AppData>(context).isPublicTilesLoaded();
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: onRefresh,
      onLoading: onLoading,
      enablePullUp: true,
      enableTwoLevel: true,
      header: WaterDropMaterialHeader(
        offset: 55,
        distance: 40,
      ),
      footer: ClassicFooter(
        height: 80,
        loadStyle: LoadStyle.ShowAlways,
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          CustomSliverAppBar(
            title: Text(
              "سواليفهم",
              style: TextStyle(color: Colors.white),
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
