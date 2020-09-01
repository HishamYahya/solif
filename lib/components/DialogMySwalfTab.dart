import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/DialogMySwalfTabModel.dart';
import 'package:solif/models/Salfh.dart';

import '../constants.dart';
import 'ColoredDot.dart';

final firestore = Firestore.instance;

class DialogMySwalfTab extends StatefulWidget {
  final String userID;

  DialogMySwalfTab({this.userID});

  @override
  _DialogMySwalfTabState createState() => _DialogMySwalfTabState();
}

class _DialogMySwalfTabState extends State<DialogMySwalfTab> {
  bool adding = false;
  bool loading = true;
  List<Widget> items = [];

  Future<void> getSalfhTiles() async {
    print(widget.key);
    List<Widget> tiles = [];
    final QuerySnapshot snapshot = await firestore
        .collection('Swalf')
        .where('adminID',
            isEqualTo:
                Provider.of<AppData>(context, listen: false).currentUserID)
        .getDocuments();

    for (DocumentSnapshot doc in snapshot.documents) {
      tiles.add(SalfhTile(
        title: doc['title'],
        id: doc.documentID,
        colorsStatus: doc['colorsStatus'],
        lastMessageSent: doc['lastMessageSent'],
        tags: doc['tags'],
        adminID: doc['adminID'],
        isInviteTile: true,
      ));
    }

    if (tiles.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
          child: Text(
            "ما عندك سواليف مفتوحة",
            style: kHeadingTextStyle.copyWith(
              fontSize: 20,
              color: Colors.grey[300],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
    setState(() {
      loading = false;
      items = tiles;
    });
  }

  void addToSalfh() async {
    String id = Provider.of<DialogMySwalfTabModel>(context, listen: false)
        .selectedSalfhID;
    String color = Provider.of<DialogMySwalfTabModel>(context, listen: false)
        .selectedSalfhColor;
    setState(() {
      adding = true;
    });
    if (id != null)
      await addUserToSalfh(
        userID: widget.userID,
        salfhID: id,
        colorName: color,
        context: context,
      );
    if (mounted) {
      setState(() {
        adding = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSalfhTiles();
  }

  @override
  Widget build(BuildContext context) {
    return adding
        ? LoadingWidget(
            'نضيفهم للسالفة...',
            color: Colors.white,
          )
        : ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height * 0.6),
              width: double.infinity,
              child: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: loading ? [LoadingWidget('')] : items,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 100),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: Provider.of<DialogMySwalfTabModel>(context)
                                  .selectedSalfhID ==
                              null
                          ? null
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: FlatButton(
                                onPressed: addToSalfh,
                                color: kMainColor,
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.white),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "اضافة",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
