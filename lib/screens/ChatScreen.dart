import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/components/MessageTile.dart';
import 'package:solif/constants.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  final Color color;

  ChatScreen({this.title, this.color});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageTile> messages = getMessages();
  final TextEditingController messageController = TextEditingController();

  static List<MessageTile> getMessages() {
    List<MessageTile> tiles = List<MessageTile>();
    List<Color> colors = [
      Colors.red[300],
      Colors.yellow,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: widget.color,
        ),
        backgroundColor: kMainColor,
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
                  return messages[messages.length - index -1];
                },
              ),
            ),
            Divider(
              color: Colors.white,
              thickness: 1.5,
              
            ),
            Container(
             
              height: 70,
              //margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
              color : Colors.grey,
             // borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                decoration: InputDecoration.collapsed(hintText: "Write..."),
                controller: messageController,
                onSubmitted: (msg){
                  setState(() {
                    messages.add(MessageTile(message: msg,color: widget.color,));  
                    messageController.clear();
                  });
                },
              ),
            )
            
          ],
        ));
  }
}
