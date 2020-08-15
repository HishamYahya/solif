import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Salfh.dart';

import '../constants.dart';
import 'ColoredDot.dart';

class DialogMySwalfTab extends StatefulWidget {
  final String userID;

  DialogMySwalfTab({this.userID});

  @override
  _DialogMySwalfTabState createState() => _DialogMySwalfTabState();
}

class _DialogMySwalfTabState extends State<DialogMySwalfTab> {
  String selectedSalfhID;
  String selectedSalfhColorName;
  bool loading = false;

  List<Widget> getSalfhTiles(List<SalfhTile> userSwalf) {
    final List<Widget> tiles = [];
    for (SalfhTile tile in userSwalf) {
      if (tile.adminID ==
              Provider.of<AppData>(context, listen: false).currentUserID ||
          true) {
        String colorName;
        GlobalKey<SalfhTileState> key = tile.key;
        for (var color in key.currentState.colorsStatus.keys) {
          if (key.currentState.colorsStatus[color] == null) {
            colorName = color;
            break;
          }
        }
        print(key.currentState.colorsStatus);
        tiles.add(
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200],
                ),
              ),
            ),
            child: ListTile(
              enabled: !key.currentState.isFull,
              selected: selectedSalfhID == tile.id,
              trailing: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 150),
                    switchOutCurve: Curves.easeOutCirc,
                    switchInCurve: Curves.easeInCirc,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: selectedSalfhID == tile.id
                        ? ColoredDot(
                            kOurColors[colorName],
                            key: UniqueKey(),
                          )
                        : ColoredDot(
                            Colors.transparent,
                            key: UniqueKey(),
                          ),
                  ),
                ),
              ),
              title: Text(
                tile.title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[850],
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Row(
                children: generateDots(key.currentState.colorsStatus),
              ),
              onTap: () {
                setState(
                  () {
                    if (selectedSalfhID == tile.id) {
                      selectedSalfhColorName = null;
                      selectedSalfhID = null;
                    } else {
                      selectedSalfhColorName = colorName;
                      selectedSalfhID = tile.id;
                    }
                  },
                );
              },
            ),
          ),
        );
      }
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
    return tiles;
  }

  List<Widget> generateDots(colorsStatus) {
    List<Widget> newDots = [];
    colorsStatus.forEach(
      (name, id) {
        // if someone is in the salfh with that color
        if (id != null) {
          newDots.add(
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ColoredDot(kOurColors[name]),
            ),
          );
        }
      },
    );

    return newDots;
  }

  void addToSalfh() async {
    setState(() {
      loading = true;
    });
    if (selectedSalfhID != null)
      await addUserToSalfh(
        userID: widget.userID,
        salfhID: selectedSalfhID,
        colorName: selectedSalfhColorName,
        context: context,
      );
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
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
                  FutureBuilder<List<SalfhTile>>(
                    future: Provider.of<AppData>(context).usersSalfhTiles,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.done:
                          List<SalfhTile> userSwalf = snapshot.data;
                          return ListView(
                            shrinkWrap: false,
                            children: getSalfhTiles(userSwalf),
                          );
                        default:
                          return snapshot.hasError
                              ? OurErrorWidget()
                              : LoadingWidget("");
                      }
                    },
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
                      child: selectedSalfhID == null
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
