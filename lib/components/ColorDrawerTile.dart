import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/models/AppData.dart';

import '../constants.dart';

class ColorDrawerTile extends StatelessWidget {
  final bool isCreator;
  final bool currentUserIsAdmin;
  final String color;
  final String id;

  ColorDrawerTile(
      {this.isCreator, this.color, this.id, this.currentUserIsAdmin});

  List<Widget> getIcons() {
    final icons = [
      IconButton(
          icon: Icon(
            Icons.report,
            color: Colors.grey[200],
          ),
          onPressed: null),
      IconButton(
          icon: Icon(
            Icons.thumbs_up_down,
            color: Colors.white,
          ),
          onPressed: null),
    ];
    if (currentUserIsAdmin)
      icons.insert(
        0,
        IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.grey[200],
            ),
            onPressed: null),
      );
    return icons;
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = Provider.of<AppData>(context).currentUserID == id;
    return ListTile(
      subtitle: isCreator
          ? Text(
              'راعي السالفة',
              style: TextStyle(fontSize: 16),
            )
          : null,
      contentPadding: EdgeInsets.only(left: 20),
      title: Container(
        decoration: BoxDecoration(
          color: kOurColors[color].withAlpha(240),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            bottomLeft: Radius.circular(40),
          ),
        ),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.095,
        child: !isCurrentUser
            ? Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: getIcons(),
              )
            : SizedBox(),
      ),
    );
  }
}
