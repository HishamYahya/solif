import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ColorDrawerTile.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Salfh.dart';

class ChatScreenDrawer extends StatefulWidget {
  final String title;
  final String adminID;
  final Map colorsStatus;
  final String color;
  final String salfhID;

  ChatScreenDrawer(
      {this.title, this.adminID, this.colorsStatus, this.color, this.salfhID});
  @override
  _ChatScreenDrawerState createState() => _ChatScreenDrawerState();
}

class _ChatScreenDrawerState extends State<ChatScreenDrawer> {
  List<Widget> generateColorTiles() {
    List<Widget> colorTiles = [];

    widget.colorsStatus.forEach((color, id) {
      if (id != Provider.of<AppData>(context, listen: false).currentUserID &&
          id != null) {
        colorTiles.add(
          ColorDrawerTile(
            color: color,
            id: id,
            isCreator: id == widget.adminID,
            salfhID: widget.salfhID,
            currentUserIsAdmin:
                Provider.of<AppData>(context, listen: false).currentUserID ==
                    widget.adminID,
          ),
        );
      }
    });
    return colorTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: kOurColors[widget.color],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30,
                ),
                child: ListTile(
                  enabled: false,
                  title: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 8.0),
            //   child: Divider(
            //     endIndent: 40,
            //     color: kMainColor,
            //   ),
            // ),
            // ListTile(
            //   enabled: false,
            //   title: Text(
            //     'الأعضاء',
            //     style: TextStyle(
            //         color: kMainColor,
            //         fontSize: 36,
            //         fontWeight: FontWeight.normal),
            //   ),
            // ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: generateColorTiles(),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 16.0),
            //   child: Divider(
            //     color: kMainColor,
            //     endIndent: 40,
            //   ),
            // ),
            Container(
              decoration: BoxDecoration(
                color: Colors.red[300],
                borderRadius: BorderRadius.only(
                  // topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    removeUser(
                      salfhID: widget.salfhID,
                      userColor: widget.color,
                    ).then((value) => Navigator.of(context)
                        .popUntil((route) => route.isFirst));
                    //.catchError((){
                    // return OurErrorWidget(errorMessage: 'Unexpected Error');
                    //});
                  },
                  child: ListTile(
                    trailing: Icon(Icons.exit_to_app, color: Colors.white),
                    title: Text(
                      'اطلع من السالفة',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
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
