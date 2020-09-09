import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';

class TagChip extends StatelessWidget {
  final String tagName;
  final Function onRemove;
  //final Function(String) onCancelPressed;

  TagChip({this.tagName, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 200,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(500),
              ),
              color: kMainColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 2,
                  blurRadius: 1,
                  offset: Offset(-2, 0), // changes position of shadow
                ),
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.clear,
                  size: 18,
                  color: kDarkModeTextColor60,
                ),
                SizedBox(width: 5),
                Text(
                  tagName,
                  style: TextStyle(
                    color: kDarkModeTextColor87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
