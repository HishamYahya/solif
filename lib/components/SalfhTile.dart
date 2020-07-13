import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/components/DropdownCard.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Tag.dart';
import 'package:solif/screens/ChatScreen.dart';

final firestore = Firestore.instance;

class SalfhTile extends StatefulWidget {
  final String title;
  final String id;
  final Map colorsStatus;
  final List tags;
  final String creatorID;
  // ['chatID'] == false

  final Map lastMessageSent;
  final DateTime lastMessageSentTime;
  SalfhTile(
      {this.title,
      this.id,
      this.colorsStatus,
      this.lastMessageSent,
      this.tags,
      this.creatorID})
      : this.lastMessageSentTime = lastMessageSent.containsKey('timeSent')
            ? lastMessageSent['timeSent'].toDate()
            : DateTime(1999);

  @override
  _SalfhTileState createState() => _SalfhTileState();
}

class _SalfhTileState extends State<SalfhTile>
    with SingleTickerProviderStateMixin {
  String colorName;
  Map colorsStatus;
  List<Widget> dots = [];
  bool isFull = false;
  bool isDetailsOpen = false;
  StreamSubscription<DocumentSnapshot> listener;
  Map lastMessageSent = {};
  bool notRead = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SharedPreferences prefs =
        Provider.of<AppData>(context, listen: false).prefs;
    if (prefs.containsKey(widget.id)) {
      DateTime lastLeft = DateTime.parse(prefs.getString(widget.id));
      print(lastLeft);
      print(widget.lastMessageSentTime);
      if (lastLeft.compareTo(widget.lastMessageSentTime) > 0) {
        notRead = false;
      }
    }
    colorsStatus = widget.colorsStatus;
    lastMessageSent = widget.lastMessageSent;
    updateTileColor();
    listener = firestore
        .collection('Swalf')
        .document(widget.id)
        .snapshots()
        .listen((snapshot) {
      if (!mapEquals(colorsStatus, snapshot.data['colorsStatus'])) {
        //update local colorsStatus state
        colorsStatus = snapshot.data['colorsStatus'];
        updateTileColor();
      }
      // new last message sent
      if (!mapEquals(lastMessageSent, snapshot.data['lastMessageSent'])) {
        setState(() {
          lastMessageSent = snapshot.data['lastMessageSent'];
          notRead = true;
        });
      }
    });
  }

  //gets color of tile
  updateTileColor() {
    String newColorName;

    colorsStatus.forEach((name, id) {
      if (id == Provider.of<AppData>(context, listen: false).currentUserID)
        newColorName = name;
    });
    if (newColorName == null)
      colorsStatus.forEach((name, id) {
        if (id == null) {
          newColorName = name;
        }
      });
    setState(() {
      //TODO: design full mode
      if (newColorName != null) {
        isFull = false;
        colorName = newColorName;
      } else {
        isFull = true;
      }
    });
  }

  List<Widget> generateDots(data) {
    List<Widget> newDots = [];
    data['colorsStatus'].forEach((name, id) {
      // if someone is in the salfh with that color
      if (id != null) {
        newDots.add(Padding(
          padding: const EdgeInsets.all(5.0),
          child: ColoredDot(kOurColors[name]),
        ));
      }
    });
    newDots.add(GestureDetector(
      onTap: () {
        setState(() {
          isDetailsOpen = !isDetailsOpen;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Icon(!isDetailsOpen
            ? Icons.keyboard_arrow_down
            : Icons.keyboard_arrow_up),
      ),
    ));
    return newDots;
  }

  setUserLastLeft() async {
    final firestore = Firestore.instance;
    await firestore.collection("chatRooms").document(widget.id).setData({
      'lastLeftStatus': {
        colorName: DateTime.now().add(Duration(
            days:
                3650)) // when the user is in, set the time he last left to infinity.
      }
    }, merge: true);

    ///// using transactions
    // final ref = firestore.collection('chatRooms').document(widget.id);
    // await firestore.runTransaction((transaction) async {
    //   final snapshot = await transaction.get(ref);
    //   if (snapshot.exists) {
    //     if (DateTime.now()
    //             .add(Duration(days: 3000))
    //             .compareTo(snapshot.data[colorName]) >
    //         0) {
    //       transaction.update(
    //           ref, {colorName: DateTime.now().add(Duration(days: 3650))});
    //     }
    //   }
    // });

    // Map<String, dynamic> salfh =
    //     await salfhDoc.get().then((value) => value.data);

    // Map colorStatus = salfh['colorsStatus'];
    // colorStatus[colorName]['isInChatRoom'] = true;
    // colorStatus[colorName]['lastMessageReadID'] = salfh['lastMessageSentID'];
    // if (colorStatus[colorName]['lastMessageReadID'] == null) return;

    // colorStatus[colorName]['isInChatRoom'] = true;
    // DocumentReference oldCheckPoint = firestore
    //     .collection("chatRooms")
    //     .document(widget.id)
    //     .collection('messages')
    //     .document(colorStatus[colorName]['lastMessageReadID']);
    // oldCheckPoint.setData({
    //   'isCheckPointMessage': {colorName: false}
    // }, merge: true);
    // DocumentReference newCheckPoint = firestore
    //     .collection("chatRooms")
    //     .document(widget.id)
    //     .collection('messages')
    //     .document(salfh['lastMessageSentID']);

    // newCheckPoint.setData({
    //   'isCheckPointMessage': {colorName: true}
    // }, merge: true);

    // salfhDoc.updateData(salfh);
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!isFull) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                title: this.widget.title,
                color: colorName,
                salfhID: this.widget.id,
                colorsStatus: colorsStatus,
                creatorID: widget.creatorID,
              ),
            ),
          ).then((value) {
            setState(() {
              notRead = false;
            });
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: isFull ? Colors.white : kOurColors[colorName],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.only(
                    topRight: Radius.elliptical(10, 50),
                    bottomRight: Radius.elliptical(10, 50),
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  color: Colors.white,
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.4,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      (widget.title +
                                          ' notRead:' +
                                          notRead.toString()),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey[850],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 4.0, left: 2),
                                  child: StreamBuilder(
                                      stream: firestore
                                          .collection('Swalf')
                                          .document(widget.id)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          colorsStatus =
                                              snapshot.data['colorsStatus'];
                                          return Row(
                                            children:
                                                generateDots(snapshot.data),
                                          );
                                        }
                                        return Padding(
                                            padding: EdgeInsets.all(5));
                                      }),
                                ),
                              ],
                            ),
                            lastMessageSent.isNotEmpty
                                ? MostRecentMessageBox(
                                    lastMessageSent: lastMessageSent,
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                      DropdownCard(
                          isOpen: isDetailsOpen,
                          tags: widget.tags,
                          colorName: colorName),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: isFull
                    ? Row(
                        children: <Widget>[
                          Text(
                            "فل",
                            style: TextStyle(fontSize: 20),
                          ),
                          Icon(
                            Icons.close,
                            color: Colors.black,
                          )
                        ],
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MostRecentMessageBox extends StatelessWidget {
  const MostRecentMessageBox({
    Key key,
    @required this.lastMessageSent,
  }) : super(key: key);

  final Map lastMessageSent;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
              minWidth: MediaQuery.of(context).size.width * 0.25),
          decoration: BoxDecoration(
            color: kOurColors[lastMessageSent['color']],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: IntrinsicWidth(
              child: Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 8.0, bottom: 8.0, left: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        lastMessageSent['content'],
                        style: TextStyle(
                            color: Colors.white, fontSize: 16.5, height: 1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        formatDate(lastMessageSent['timeSent'].toDate(),
                            [hh, ':', mm]),
                        style: TextStyle(
                            color: Colors.grey[200], fontSize: 14, height: 1),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
