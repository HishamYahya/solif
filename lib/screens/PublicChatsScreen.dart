import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/SliverSearchBar.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import '../components/TagSearchResultsList.dart';

class PublicChatsScreen extends StatefulWidget {
  final bool disabled;

  PublicChatsScreen({this.disabled});

  @override
  _PublicChatsScreenState createState() => _PublicChatsScreenState();
}

class _PublicChatsScreenState extends State<PublicChatsScreen>
    with SingleTickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  FocusNode _searchBarFocusNode = FocusNode();
  String searchTerm = "";
  TabController _tabController;
  final GlobalKey<NestedScrollViewState> _scrollViewKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchBarFocusNode.addListener(() {
      _scrollViewKey.currentState.outerController.jumpTo(0);
      _tabController.animateTo(_searchBarFocusNode.hasFocus ? 1 : 0);
    });
  }

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
    return NestedScrollView(
      key: _scrollViewKey,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverSearchBar(
            focusNode: _searchBarFocusNode,
            onChange: (value) {
              setState(() {
                searchTerm = value;
              });
            }),
      ],
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          Tab(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: onRefresh,
              onLoading: onLoading,
              enablePullUp: true,
              enableTwoLevel: true,
              header: WaterDropMaterialHeader(
                offset: 0,
                distance: 40,
              ),
              footer: ClassicFooter(
                height: 80,
                loadStyle: LoadStyle.ShowAlways,
              ),
              child: CustomScrollView(
                slivers: <Widget>[
                  // SliverList(
                  //   delegate: SliverChildListDelegate(
                  //     [
                  //       TextField(
                  //         style: TextStyle(color: Colors.white),
                  //         decoration: InputDecoration(
                  //           enabledBorder: OutlineInputBorder(
                  //               borderSide: BorderSide(color: Colors.white),
                  //               borderRadius: BorderRadius.all(Radius.circular(30))),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  SliverList(
                    delegate: SliverChildListDelegate(
                      isLoaded
                          ? Provider.of<AppData>(context).publicSalfhTiles
                          : [LoadingWidget('...نجيب سوالفهم')],
                    ),
                  ),

                  // Container(
                  //   child: SliverStaggeredGrid.countBuilder(
                  //     itemCount: Provider.of<AppData>(context).publicSalfhTiles.length,
                  //     crossAxisCount: 2,

                  //     mainAxisSpacing: 4.0,
                  //     crossAxisSpacing: 4.0,
                  //     itemBuilder: (context, index) {
                  //       return Provider.of<AppData>(context).publicSalfhTiles[index];
                  //     },
                  //     staggeredTileBuilder: (index) {
                  //       return StaggeredTile.count(3, 4);
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          TagSearchResultsList(
            searchTerm: searchTerm,
          ),
        ],
      ),
    );
  }
}
