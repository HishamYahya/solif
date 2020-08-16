import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/models/AppData.dart';

class TagTile extends StatefulWidget {
  final String tagName;
  //final Function(String) onCancelPressed;

  const TagTile({
    Key key,
    this.tagName,
  }) : super(key: key);

  @override
  _TagTileState createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
            alignment: Alignment.topRight,
            child: IconButton(
              //onPressed: onCancelPressed(tagName),
              icon: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onPressed: () {
                Provider.of<AppData>(context,listen: false).deleteTag(this.widget.tagName);
              },
            )),
        Text(
          widget.tagName,
          style: TextStyle(color: Colors.black),
        )
      ],
    );
  }
}
