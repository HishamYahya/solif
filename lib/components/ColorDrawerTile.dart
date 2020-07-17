import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Likes.dart';

import '../constants.dart';

class ColorDrawerTile extends StatefulWidget {
  final bool isCreator;
  final bool currentUserIsAdmin;
  final String color;
  final String id;

  ColorDrawerTile(
      {this.isCreator, this.color, this.id, this.currentUserIsAdmin});

  @override
  _ColorDrawerTileState createState() => _ColorDrawerTileState();
}

class _ColorDrawerTileState extends State<ColorDrawerTile> {
  bool liking = false;
  List<bool> isSelected = [false, false]; // like button is index 0

  List<Widget> getIcons() {
    final icons = [
      IconButton(
          icon: Icon(
            Icons.report,
            color: Colors.grey[200],
          ),
          onPressed: null),
      AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        transitionBuilder: (child, animation) => ScaleTransition(
          alignment: Alignment.center,
          scale: animation,
          child: child,
        ),
        child: !liking
            ? IconButton(
                icon: Icon(
                  Icons.thumbs_up_down,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    liking = true;
                  });
                })
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
                child: ToggleButtons(
                  renderBorder: false,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                  borderColor: kOurColors[widget.color],
                  selectedColor: isSelected[1] ? Colors.red : Colors.green,
                  fillColor: isSelected[1]
                      ? Colors.red.withAlpha(30)
                      : Colors.green.withAlpha(30),
                  children: [
                    Icon(Icons.thumb_up),
                    Icon(Icons.thumb_down),
                  ],
                  isSelected: isSelected,
                  onPressed: (index) {
                    final prevSelected = [...isSelected];
                    print(widget.id);
                    setState(() {
                      if (!isSelected[index]) {
                        isSelected[index] = true;
                        isSelected[(index - 1).abs()] = false;
                      } else {
                        isSelected[index] = false;
                      }
                    });
                    final currentUserID =
                        Provider.of<AppData>(context, listen: false)
                            .currentUserID;
                    if (!isSelected[0] && !isSelected[0]) {
                      // when removing like/dislike
                      prevSelected[0]
                          ? unLikeUser(currentUserID, widget.id)
                          : unDislikeUser(currentUserID, widget.id);
                    } else {
                      isSelected[0]
                          ? likeUser(currentUserID, widget.id)
                          : dislikeUser(currentUserID, widget.id);
                    }
                    Future.delayed(Duration(milliseconds: 100)).then((value) {
                      setState(() {
                        liking = false;
                      });
                    });
                  },
                ),
              ),
      ),
    ];
    if (widget.currentUserIsAdmin)
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
    final isCurrentUser =
        Provider.of<AppData>(context).currentUserID == widget.id;
    return ListTile(
      subtitle: widget.isCreator
          ? Text(
              'راعي السالفة',
              style: TextStyle(fontSize: 16),
            )
          : null,
      contentPadding: EdgeInsets.only(left: 20),
      title: Container(
        decoration: BoxDecoration(
          color: kOurColors[widget.color].withAlpha(240),
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
