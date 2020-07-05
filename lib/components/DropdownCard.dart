import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import '../constants.dart';

class DropdownCard extends StatefulWidget {
  final bool isOpen;
  final List tags;
  final String colorName;

  DropdownCard({this.isOpen, this.tags, this.colorName});
  @override
  _DropdownCardState createState() => _DropdownCardState();
}

class _DropdownCardState extends State<DropdownCard>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;

  @override
  void initState() {
    // TODO: implement initState
    isOpen = this.isOpen;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 150),
      child: Container(
        decoration: BoxDecoration(
            color: kOurColors[widget.colorName],
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10))),
        constraints: widget.isOpen
            ? BoxConstraints(maxHeight: double.maxFinite)
            : BoxConstraints(maxHeight: 0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Tags(
                columns: 2,
                itemCount: widget.tags.length,
                itemBuilder: (index) {
                  final item = widget.tags[index];

                  return ItemTags(
                    // Each ItemTags must contain a Key. Keys allow Flutter to
                    // uniquely identify widgets.
                    key: Key(index.toString()),
                    index: index, // required
                    title: item,
                    activeColor: Colors.white,
                    color: Colors.white,

                    textStyle: TextStyle(
                      fontSize: 18,
                    ),
                    textActiveColor: Colors.grey[800],
                    textColor: Colors.grey[800],
                    splashColor: Colors.transparent,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
