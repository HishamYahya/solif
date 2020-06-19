import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ChatInputBox.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/MessageTile.dart';
import 'package:solif/components/TypingWidgetRow.dart';
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
  String inputMessage = "";
  Map colorsStatus;
  Map<String,Timestamp> lastLeftStatus; 
  String colorName;
  bool isInSalfh = false;
  bool joining = false;
  bool sending = false;
  TypingWidgetRow typingWidgetRow;
  TextEditingController messageController = TextEditingController();
  StreamSubscription<DocumentSnapshot> colorStatusListener;
  StreamSubscription<DocumentSnapshot> timeLastLeftListener;

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
      typingWidgetRow = TypingWidgetRow(colorsStatus: colorsStatus);
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
    listenToLastLeftChanges();
    listenToColorStatusChanges();
    super.initState();
  }

  // listen to changes in the colorsStatus in the database
  void listenToColorStatusChanges() {
    colorStatusListener = firestore
        .collection('Swalf')
        .document(widget.salfhID)
        .snapshots()
        .listen((snapshot) {
      // print("HERE@#@!"); 
      // print(snapshot.data);
      Map newColorsStatus = snapshot.data['colorsStatus'];
      if (!mapEquals(colorsStatus, newColorsStatus)) {
        setState(() {
          colorsStatus = newColorsStatus;
        });
      }
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

  void listenToLastLeftChanges() {
    timeLastLeftListener = firestore
        .collection('chatRooms')
        .document(widget.salfhID)
        .snapshots()
        .listen((event) {
          print("OK"); 
          print(event.data);
          Map<String,Timestamp> newStatus = Map<String,Timestamp>.from(event.data);
          // print("hereeee${event.data}");
                if (!mapEquals(lastLeftStatus, newStatus)) {
        setState(() {
          lastLeftStatus = newStatus;
        });
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
      _changeTypingTo(false);
    } else {
      bool joined;
      joined = await _joinSalfh();
      if (joined) {
        setState(() {
          isInSalfh = true;
        });
        Provider.of<AppData>(context, listen: false).reloadUsersSalfhTiles();
        sendMessage();
        _changeTypingTo(false);
      }
    }
    setState(() {
      inputMessage = '';
    });
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

  Future<void> setUserTimeLeft() async {
    final firestore = Firestore.instance;
    await firestore
        .collection("chatRooms")
        .document(widget.salfhID)
        .setData({colorName: DateTime.now()}, merge: true);

    // changed this so that it rewrites the one field instead of the whole map
    // await firestore.collection("Swalf").document(widget.salfhID).setData({
    //   'colorsStatus': {
    //     colorName: {
    //       'isInChatRoom': false,
    //     }
    //   }
    // }, merge: true);
  }

  void _changeTypingTo(bool isTyping) {
    firestore.collection('Swalf').document(widget.salfhID).setData({
      'colorsStatus': {
        colorName: {
          'isTyping': isTyping,
        }
      }
    }, merge: true);
  }

  void updateTyping(String newInputMessage) {
    if (inputMessage.isEmpty && newInputMessage.isNotEmpty) {
      _changeTypingTo(true);
    } else if (inputMessage.isNotEmpty && newInputMessage.isEmpty) {
      _changeTypingTo(false);
    }
  }

  void _onClose() async {
    colorStatusListener.cancel();
    timeLastLeftListener.cancel();
    await setUserTimeLeft();
    if (inputMessage.isNotEmpty) {
      inputMessage = '';
      _changeTypingTo(false);
    }
  }

  @override
  void dispose() {
    _onClose();
    super.dispose();
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
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            widget.title,
          ),
          backgroundColor:
              isInSalfh ? currentColor : Colors.white //.withOpacity(0.8),
          ),
      backgroundColor: Colors.blueAccent[50],
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("chatRooms")
                      .document(widget.salfhID)
                      .collection('messages').
                      orderBy('timeSent').snapshots(),
                  builder: (context, snapshot) {
                    //TODO: display the message on screen only when it's been written to the database
                    if (!snapshot.hasData) {
                      return LoadingWidget("");
                    }
                    final messages = snapshot.data.documents.reversed;
                    Set<String> alreadyRead = Set<String>(); 
                    List<Widget> messageTiles = [];;
                    for (var message in messages) {
                      
                      List<String> readColors = []; 
                      lastLeftStatus.forEach((color, lastLeft) {
                        if(message['color'] != color && !alreadyRead.contains(color) && lastLeft.compareTo(message['timeSent']) > 0){
                          readColors.add(color);
                          alreadyRead.add(color); 
                        }
                      });  

                      messageTiles.add(MessageTile(
                        color: message['color'],
                        message: message["content"],
                        fromUser: message['color'] == colorName,
                        readColors: readColors

                        //
                        // add stuff here when you update messageTile
                        // time: message["time"],
                        //
                      ));
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      itemCount: messageTiles.length,
                      itemBuilder: (context, index) {
                        return messageTiles[index];
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 5,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Center(
                      child: TypingWidgetRow(colorsStatus: colorsStatus)),
                )
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
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
                  color: Colors.white,
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
                            if (isInSalfh) {
                              updateTyping(value);
                            }
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
      ),
    );
  }
}
