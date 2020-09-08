import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Preferences.dart';

class ChatScreenAppBar extends StatelessWidget {
  final Function onLeave;
  final Function onOpenDrawer;
  final bool isInSalfh;
  final String color;

  ChatScreenAppBar(
      {this.onLeave, this.onOpenDrawer, this.isInSalfh, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipOval(
            child: Container(
              color: kMainColor,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
              ),
            ),
          ),
          isInSalfh
              ? ClipOval(
                  child: Container(
                    color:
                        Provider.of<Preferences>(context).currentColors[color],
                    child: IconButton(
                      icon: Icon(Icons.view_stream),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      color: Colors.white,
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
