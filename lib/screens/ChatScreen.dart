import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/components/ChatInputBox.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/MessageTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Message.dart';

final firestore = Firestore.instance;

class ChatScreen extends StatefulWidget {
  final String title;
  final String color;
  final String salfhID;

  final VoidCallback onUpdate;

  ChatScreen({this.title, this.color, this.salfhID = "000test",this.onUpdate});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageTile> messages = getMessages();
  String inputMessage;

  static List<MessageTile> getMessages() {
    List<MessageTile> tiles = List<MessageTile>();

    Random r = Random();
    for (int i = 0; i < 20; i++) {
      tiles.add(MessageTile(
        message: "message$i",
        color: kColorNames[r.nextInt(5)],
      ));
    }
    return tiles;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backGround = Colors.white;
    Color currentColor = kOurColors[widget.color];
    final TextEditingController messageController = TextEditingController();
    //////////////////// hot reload to add message
    return Scaffold(
        appBar: AppBar(
            title: Text(
              widget.title,
            ),
            backgroundColor: currentColor //.withOpacity(0.8),
            ),
        backgroundColor: Colors.blueAccent[50],
        body: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("Swalf")
                  .document(widget.salfhID)
                  .collection('messages')
                  .orderBy("timeSent")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LoadingWidget();
                }
                //return Text("XD");
                final messages = snapshot.data.documents.reversed;
                List<MessageTile> messageTiles = [];
                for (var message in messages) {
                  messageTiles.add(MessageTile(
                    color: message['color'],
                    message: message["content"],
                    fromUser: message['color'] == widget.color,
                    //
                    // add stuff here when you update messageTile
                    // time: message["time"],
                    //
                  ));
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: ListView.builder(
                      reverse: true,
                      // padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return messageTiles[index];
                      },
                    ),
                  ),
                );
              },
            ),
            Container(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0,
                      color: Colors.grey[200],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(150),
                    ),
                    color: kOurColors[widget.color].withAlpha(70),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: ChatInputBox(
                            color: currentColor,
                            messageController: messageController,
                            onChanged: (String value) {
                              inputMessage = value;
                            },
                            onSubmit: (_) {
                              addMessage(
                                  inputMessage, widget.color, widget.salfhID);
                              messageController.clear();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        FloatingActionButton(
                          backgroundColor: currentColor,
                          child: Icon(Icons.send),
                          onPressed: () {
                            if (inputMessage == "" || inputMessage == null) {
                              return;
                            }
                            addMessage(
                                inputMessage, widget.color, widget.salfhID);
                            messageController.clear();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}



