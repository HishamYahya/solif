import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/DialogMySwalfTab.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/DialogMySwalfTabModel.dart';
import 'package:solif/models/Preferences.dart';

import '../constants.dart';
import 'ColoredDot.dart';

class InviteSalfhTile extends StatefulWidget {
  final bool isFull;
  final String color;
  final String title;
  final Map colorsStatus;
  final String id;

  InviteSalfhTile({
    @required this.isFull,
    @required this.color,
    @required this.title,
    @required this.colorsStatus,
    @required this.id,
  });

  @override
  _InviteSalfhTileState createState() => _InviteSalfhTileState();
}

class _InviteSalfhTileState extends State<InviteSalfhTile> {
  @override
  void initState() {
    super.initState();
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
              child: ColoredDot(
                  Provider.of<Preferences>(context).currentColors[name]),
            ),
          );
        }
      },
    );

    return newDots;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200],
          ),
        ),
      ),
      child: ListTile(
        enabled: !widget.isFull,
        selected: Provider.of<DialogMySwalfTabModel>(context).selectedSalfhID ==
            widget.id,
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
              child:
                  Provider.of<DialogMySwalfTabModel>(context).selectedSalfhID ==
                          widget.id
                      ? ColoredDot(
                          Provider.of<Preferences>(context)
                              .currentColors[widget.color],
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
          widget.title,
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[850],
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: generateDots(widget.colorsStatus),
        ),
        onTap: () {
          Provider.of<DialogMySwalfTabModel>(context, listen: false)
              .selectSalfh(salfhID: widget.id, color: widget.color);
        },
      ),
    );
  }
}
