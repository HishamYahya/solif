import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';

class TagTile extends StatelessWidget {
  final String tagName;
  int index; 
  //final Function(String) onCancelPressed;

  TagTile({
    Key key,
    this.tagName,
    this.index
  }) : super(key: key);

  @override
    Widget build(BuildContext context) {
    print("yo $key");  
    return ItemTags(  
      // highlightColor: Colors.green,
      // activeColor: Colors.black,
      activeColor: kMainColor,

      key: key,
      index: index,
      active: true,
      
      title: tagName,
      borderRadius: BorderRadius.all(Radius.circular(20)) ,
      // textColor: Colors.black,
      // color:  Colors.white, //kOurColors[kColorNames[index % 5]]
      padding: EdgeInsets.all(15), 
      alignment: MainAxisAlignment.center,
      //icon: ItemTagsIcon(icon: Icons.tag_faces),
      onPressed: (i) {
        showDialog(context: context,child: AlertDialog(title: Text("Are you sure")));
      },
      removeButton: ItemTagsRemoveButton(),

    );
  }
}

