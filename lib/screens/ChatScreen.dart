import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/components/ChatInputBox.dart';
import 'package:solif/components/MessageTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Message.dart';
import 'package:solif/models/Salfh.dart';

final firestore = Firestore.instance;

class ChatScreen extends StatefulWidget {
  final String title;
  final Color color;

  ChatScreen({this.title, this.color});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageTile> messages = getMessages();
  String inputMessage;

  static List<MessageTile> getMessages() {
    List<MessageTile> tiles = List<MessageTile>();
    List<Color> colors = [
      Colors.red[300],
      Colors.blueAccent,
      Colors.green[300]
    ];

    Random r = Random();
    for (int i = 0; i < 6; i++) {
      tiles.add(MessageTile(
        message: "message$i",
        color: colors[r.nextInt(3)],
      ));
    }
    return tiles;
  }

  //////////////////////////////////////////////////////////////////////////////

  // holds salfh id
  String salfhID;
  void saveDoc() async {
    /////////////////// approach without using models kinda
    // try {
    //   final ref = await firestore.collection("Swalf").add({
    //     'messages': ["oisdfjsf", "soidfjsd", "isofj"],
    //     'users': ['a', 'b', 'c'],
    //     'category': "category",
    //     'numOfUsers': 2,
    //     'type': "type"
    //   });

    //   await firestore
    //       .collection('Swalf')
    //       .document(ref.documentID)
    //       .setData({'id': ref.documentID}, merge: true);
    // } catch (e) {
    //   print(e);
    // }

    try {
      // generate unique id for salfh
      salfhID = firestore.collection("Swalf").document().documentID;

      // save salfh info
      await firestore.collection('Swalf').document(salfhID).setData(Salfh(
            id: salfhID,
            maxUsers: 3,
            type: "type",
            userIDs: ["sdjfsdf", "oisdfiosj", "sdifjo"],
          ).toMap());
    } catch (e) {}
  }

  void addMessage() {
    if (salfhID != null) {
      // generate unique message key
      final messageKey = firestore
          .collection("Swalf")
          .document(salfhID)
          .collection("messages")
          .document()
          .documentID;

      // save message with generated key
      firestore
          .collection("Swalf")
          .document(salfhID)
          .collection("messages")
          .document(messageKey)
          .setData(Message(
                  id: messageKey,
                  content: "contenttt",
                  timeSent: DateTime.now(),
                  senderID: "siodfjiosdf")
              .toMap());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // creates new salfh
    saveDoc();
  }

///////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    //////////////////// hot reload to add message
    addMessage();
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: widget.color.withOpacity(0.8),
        ),
        backgroundColor: widget.color.withOpacity(0.8),
        body: Column(
          children: <Widget>[
            // StreamBuilder<QuerySnapshot>(
            //   stream: Firestore.instance.collection("messages").snapshots(),
            // collection structure neeeded first.
            // ),

            Expanded(
              child: ListView.builder(
                reverse: true,
                // padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return messages[messages.length - index - 1];
                },
              ),
            ),
            Divider(
              height: 4,
              color: Colors.white,
              thickness: 1.5,
            ),
            ChatInputBox(
              color: widget.color,
              onChanged: (String value) {
                inputMessage = value;
              },
              onSubmit: (_) {
                setState(() {
                  messages.add(MessageTile(
                    color: widget.color,
                    message: inputMessage,
                  ));
                });
              },
            )
          ],
        ));
  }
}
