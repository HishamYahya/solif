import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/AppData.dart';

import '../constants.dart';
import 'ColoredDot.dart';

class DialogMySwalfTab extends StatefulWidget {
  @override
  _DialogMySwalfTabState createState() => _DialogMySwalfTabState();
}

class _DialogMySwalfTabState extends State<DialogMySwalfTab> {
  List<SalfhTile> selectedSwalf = [];

  List<Widget> getSalfhTiles() {
    final List<Widget> tiles = [];
    for (SalfhTile tile in Provider.of<AppData>(context).publicSalfhTiles) {
      if (tile.adminID ==
              Provider.of<AppData>(context, listen: false).currentUserID ||
          true) {
        GlobalKey<SalfhTileState> key = tile.key;
        Color color = Colors.black;
        for (var colorName in key.currentState.colorsStatus.keys) {
          if (key.currentState.colorsStatus[colorName] == null) {
            color = kOurColors[colorName];
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
              selected: selectedSwalf.contains(tile),
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
                    child: selectedSwalf.contains(tile)
                        ? ColoredDot(
                            color,
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
                setState(() {
                  selectedSwalf.contains(tile)
                      ? selectedSwalf.remove(tile)
                      : selectedSwalf.add(tile);
                });
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
            minHeight: 0, maxHeight: MediaQuery.of(context).size.height * 0.6),
        width: double.infinity,
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: getSalfhTiles(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: selectedSwalf.isEmpty
                    ? null
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: FlatButton(
                          onPressed: () {},
                          color: kMainColor,
                          shape: StadiumBorder(
                            side: BorderSide(color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "اضافة",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
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
