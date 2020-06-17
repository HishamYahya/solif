import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ChatInputBox.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/MessageTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Message.dart';
import 'package:solif/models/Salfh.dart';

final firestore = Firestore.instance;

class ChatScreen extends StatefulWidget {
  final String title;
  final String color;
  final String salfhID;
  final Map colorsStatus;

  final VoidCallback onUpdate;

  ChatScreen(
      {this.title,
      this.color,
      this.salfhID = "000test",
      this.onUpdate,
      this.colorsStatus});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageTile> messages = getMessages();
  String inputMessage;
  Map colorsStatus;
  String colorName;
  bool isInSalfh = false;
  bool joining = false;
  bool sending = false;
  TextEditingController messageController = TextEditingController();

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
    // initial status
    setState(() {
      colorsStatus = widget.colorsStatus;
      colorName = widget.color;
    });
    // check if user is in salfh
    String userID = Provider.of<AppData>(context, listen: false).currentUserID;
    widget.colorsStatus.forEach((key, statusMap) {
      if (statusMap['userID'] == userID)
        setState(() {
          isInSalfh = true;
        });
    });
    listenToChanges();
    super.initState();
  }

  // listen to changes in the colorsStatus in the database
  void listenToChanges() {
    firestore
        .collection('Swalf')
        .document(widget.salfhID)
        .snapshots()
        .listen((snapshot) {
      print(snapshot);
      Map newColorsStatus = snapshot.data['colorsStatus'];
      // if someone ELSE joined with your color
      if (newColorsStatus[colorName]['userID'] != null &&
          newColorsStatus[colorName]['userID'] !=
              Provider.of<AppData>(context, listen: false).currentUserID) {
        String newColorName;
        // loop through the status until you find a color that hasn't been assigned to anyone
        newColorsStatus.forEach((name, statusMap) {
          if (statusMap['userID'] == null) {
            newColorName = name;
          }
        });
        // assign the new color to you
        if (newColorName != null) {
          setState(() {
            colorName = newColorName;
          });
        }
        // if full
        else {
          Navigator.pop(context);
        }
      }
    });
  }

  // returns true if user successfully joined
  Future<bool> _joinSalfh() async {
    setState(() {
      joining = true;
    });

    bool joined = await joinSalfh(
      userID: Provider.of<AppData>(context, listen: false).currentUserID,
      salfhID: widget.salfhID,
      colorName: colorName,
    );

    setState(() {
      joining = false;
    });

    return joined;
  }

  // sends the message only if the user successfully joined the salfh
  /// the bool state 'joining' is used to render the joining state on the ui
  void _onSubmit() async {
    setState(() {
      sending = true;
    });
    if (inputMessage == "" || inputMessage == null) {
      sending = false; 
      return;
    }
    if (isInSalfh) {
      sendMessage();
      inputMessage = '';
    } else {
      bool joined;
      joined = await _joinSalfh();
      if (joined) {
        setState(() {
          isInSalfh = true;
        });
        Provider.of<AppData>(context, listen: false).reloadUsersSalfhTiles();
        sendMessage();
      }
    } 
  }

  void sendMessage() async {
    bool success = await addMessage(inputMessage, colorName, widget.salfhID);
    if (success) {
      //TODO: display the message on screen only when it's been written to the database

      messageController.clear();
    }

    setState(() {
      sending = false;
    });
  }
  
  void setUserNotInChatRoom() async{
        final firestore = Firestore.instance;
        DocumentReference salfhDoc = firestore.collection("Swalf").document(widget.id);
        Map<String,dynamic> salfh = await salfhDoc.get().then((value) => value.data);
        Map colorStatus = salfh['colorsStatus']; 
        colorStatus[colorName]['isInChatRoom'] = false;
        salfhDoc.updateData(salfh);
  }

  @override
  Widget build(BuildContext context) {
    Color backGround = Colors.white;
    Color currentColor = kOurColors[colorName];
    //////////////////// hot reload to add message
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: (){

              Navigator.of(context).pop();
              setUserNotInChatRoom(); 
            }
          ),
            title: Text(
              widget.title,
            ),
            backgroundColor:
                isInSalfh ? currentColor : Colors.white //.withOpacity(0.8),
            ),
        backgroundColor: Colors.blueAccent[50],
        body: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection("chatRooms")
                  .document(widget.salfhID)
                  .collection('messages')
                  .orderBy("timeSent")
                  .snapshots(),
              builder: (context, snapshot) {
                //TODO: display the message on screen only when it's been written to the database
                if (!snapshot.hasData) {
                  return Expanded(
                    child: LoadingWidget(""),
                  );
                }
                //return Text("XD");
                final messages = snapshot.data.documents.reversed;
                List<MessageTile> messageTiles = [];
                for (var message in messages) {
                  messageTiles.add(MessageTile(
                    color: message['color'],
                    message: message["content"],
                    fromUser: message['color'] == colorName,
                    
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
                    color: kOurColors[colorName].withAlpha(70),
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
                              _onSubmit();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        FloatingActionButton(
                          backgroundColor: currentColor,
                          child: sending
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : Icon(Icons.send),
                          onPressed: _onSubmit,
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
