import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:solif/models/Preferences.dart';

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
            color: Provider.of<Preferences>(context)
                .currentColors[widget.colorName],
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10))),
        constraints: widget.isOpen
            ? BoxConstraints(maxHeight: double.maxFinite)
            : BoxConstraints(maxHeight: 0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(bottom: widget.tags.isEmpty ? 0 : 16.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {},
                      child: Icon(
                        Icons.report,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              widget.tags.isNotEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Tags(
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
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
