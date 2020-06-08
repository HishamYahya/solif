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
  final String color;
  final String salfhID;

  ChatScreen({this.title, this.color, this.salfhID = "00test"});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageTile> messages = getMessages();
  String inputMessage;

  static List<MessageTile> getMessages() {
    List<MessageTile> tiles = List<MessageTile>();
    List<Color> colors = [];
    for (int i = 0; i < kColorNames.length; i++) {
      colors.add(kOurColors[kColorNames[i]]);
    }

    Random r = Random();
    for (int i = 0; i < 20; i++) {
      tiles.add(MessageTile(
        message: "message$i",
        color: colors[r.nextInt(5)],
      ));
    }
    return tiles;
  }

  //////////////////////////////////////////////////////////////////////////////

  // holds salfh id
  // String salfhID;
  // void saveDoc() async {
  //   /////////////////// approach without using models kinda
  //   // try {
  //   //   final ref = await firestore.collection("Swalf").add({
  //   //     'messages': ["oisdfjsf", "soidfjsd", "isofj"],
  //   //     'users': ['a', 'b', 'c'],
  //   //     'category': "category",
  //   //     'numOfUsers': 2,
  //   //     'type': "type"
  //   //   });

  //   //   await firestore
  //   //       .collection('Swalf')
  //   //       .document(ref.documentID)
  //   //       .setData({'id': ref.documentID}, merge: true);
  //   // } catch (e) {
  //   //   print(e);
  //   // }

  //   try {
  //     // generate unique id for salfh
  //     //salfhID = firestore.collection("Swalf").document().documentID;

  //     // save salfh info
  //     await firestore.collection('Swalf').document(salfhID).setData(Salfh(
  //      //   id: salfhID,
  //           maxUsers: 3,
  //           type: "type",
  //           userIDs: {"green":"sdjfsdf", "red":"oisdfiosj", "blue":"sdifjo"},
  //         ).toMap());
  //   } catch (e) {}
  // }

  void addMessage(String messageContent) {
    String salfhID = widget.salfhID; // to avoid avoid using widget everytime.
    print(salfhID);

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
                  content: messageContent,
                  timeSent: DateTime.now(),
                  messageColor: widget.color)
              .toMap());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // print(firestore.collection("Swalf").document()
  }

///////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    Color backGround = Colors.white;
    Color currentColor = kOurColors[widget.color];
    //////////////////// hot reload to add message
    addMessage("XD");
    return Scaffold(
        appBar: AppBar(
            title: Text(
              widget.title,
            ),
            backgroundColor: currentColor //.withOpacity(0.8),
            ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
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
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: ChatInputBox(
                      color: currentColor,
                      onChanged: (String value) {
                        inputMessage = value;
                      },
                      onSubmit: (_) {
                        setState(() {
                          messages.add(MessageTile(
                            color: currentColor,
                            message: inputMessage,
                          ));
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    backgroundColor: currentColor,
                    child: Icon(Icons.send),
                    onPressed: () {
                      addMessage(inputMessage);
                      checkIfDocumentExisits();
                    },
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

void checkIfDocumentExisits() async {
  final snapShot =
      await Firestore.instance.collection('Swalf').document("00test").get();

  if (snapShot.exists) {
    print("there");
  } else {
    print("Not there");
  }
}
