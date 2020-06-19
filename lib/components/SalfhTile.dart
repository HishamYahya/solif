import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/screens/ChatScreen.dart';

final firestore = Firestore.instance;

class SalfhTile extends StatefulWidget {
  final String title;
  final String category;
  final String id;
  final Map colorsStatus;

  final DateTime
      lastMessageSentTime; // to sort user messages according to most recent message, maybe display it somewhere later on.
  // add type (1 on 1, group)
  // change to stateful and add remaining slots

  SalfhTile(
      {this.title,
      this.category,
      this.id,
      this.colorsStatus,
      this.lastMessageSentTime});

  @override
  _SalfhTileState createState() => _SalfhTileState();
}

class _SalfhTileState extends State<SalfhTile> {
  String colorName;
  Map colorsStatus;
  List<Widget> dots = [];
  bool isFull = false;
  StreamSubscription<DocumentSnapshot> listener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    colorsStatus = widget.colorsStatus;
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
    });
  }

  //gets color of tile
  updateTileColor() {
    String newColorName;

    colorsStatus.forEach((name, statusMap) {
      if (statusMap['userID'] ==
          Provider.of<AppData>(context, listen: false).currentUserID)
        newColorName = name;
    });
    if (newColorName == null)
      colorsStatus.forEach((name, statusMap) {
        if (statusMap['userID'] == null) {
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
    data['colorsStatus'].forEach((name, statusMap) {
      // if someone is in the salfh with that color
      if (statusMap['userID'] != null) {
        newDots.add(Padding(
          padding: const EdgeInsets.all(5.0),
          child: ColoredDot(kOurColors[name]),
        ));
      }
    });
    return newDots;
  }

  setUserLastLeft() async {
    final firestore = Firestore.instance;
    await firestore.collection("chatRooms").document(widget.id).setData({
      colorName: DateTime.now().add(Duration(
          days:
              3650)) // when the user is in, set the time he last left to infinity.
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
      onTap: () {
        if (!isFull) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                title: this.widget.title,
                color: colorName,
                salfhID: this.widget.id,
                colorsStatus: colorsStatus,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isFull ? Colors.white : kOurColors[colorName],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.elliptical(10, 50),
                      bottomRight: Radius.elliptical(10, 50),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[850],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, left: 2),
                      child: StreamBuilder(
                          stream: firestore
                              .collection('Swalf')
                              .document(widget.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              colorsStatus = snapshot.data['colorsStatus'];
                              return Row(
                                children: generateDots(snapshot.data),
                              );
                            }
                            return Padding(padding: EdgeInsets.all(5));
                          }),
                    )
                  ],
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
