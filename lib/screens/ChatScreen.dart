import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/components/ChatInputBox.dart';
import 'package:solif/components/ChatScreenAppBar.dart';
import 'package:solif/components/ChatScreenDrawer.dart';
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
  final String adminID;

  final VoidCallback onUpdate;

  ChatScreen(
      {this.title,
      this.color,
      this.salfhID = "000test",
      this.onUpdate,
      this.colorsStatus,
      this.adminID});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  LocalStorage storage;
  List<Map<String, dynamic>> localMessages = [];
  List<Map<String, dynamic>> allTheMessages = [];
  var lastMessageSavedLocally;
  var futureLastMessageSavedLocallyTime;
  String inputMessage = "";
  Map colorsStatus;
  Map typingStatus = {};
  Map<String, Timestamp> lastLeftStatus;
  String colorName;
  int messageCounter = 0;
  bool isInSalfh = false;
  bool joining = false;
  bool sending = false;
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
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      colorsStatus = widget.colorsStatus;
      colorName = widget.color;
    });
    setTimeLeftInfinity();
    // check if user is in salfh
    String userID = Provider.of<AppData>(context, listen: false).currentUserID;
    widget.colorsStatus.forEach((name, id) {
      if (id == userID)
        setState(() {
          isInSalfh = true;
          loadLocalStorageMessages();
        });
    });
    listenToChatroomChanges();
    listenToColorStatusChanges();

    super.initState();
  }

  Future<void> loadLocalStorageMessages() async {
    storage = new LocalStorage(widget.salfhID + '.json');
    bool isReady = await storage.ready;
    print('isReady:$isReady');

    List<dynamic> storedMessages = storage.getItem('local_messages') ?? [];
    print("local items length ${storedMessages.length}");
    storedMessages.forEach((element) {
      print(element['timeSent'].runtimeType);
      print(element['timeSent']);

      if (element['timeSent'] is String)
      {
        element['timeSent'] =
            Timestamp.fromDate(DateTime.parse(element['timeSent']));
      }
      print(element);
      print(element['timeSent'].runtimeType);
      localMessages.add(element);
    });

    // allTheMessages.addAll(storedMessages);

    lastMessageSavedLocally = storage.getItem('last_message_time') ??
        DateTime(2010); // default value last messages saved in 2010.
    lastMessageSavedLocally =
        DateTime.parse(lastMessageSavedLocally.toString());

    // storedMessages.forEach((message) {
    //   MessageTile messageTile = MessageTile(
    //       color: message['color'],
    //       message: message['content'],
    //       fromUser: message['color'] == colorName,
    //   localMessages.add(messageTile);
    // });
  }

  void populateAllMessages(List<DocumentSnapshot> snapshotMessages,
      List<Map<String, dynamic>> localMessages) {
    int snapLen = snapshotMessages.length;
    int localLen = localMessages.length;
    int allLen = allTheMessages.length;

    String testString = 'snaplen:' +
        snapLen.toString() +
        ' localLen:' +
        localLen.toString() +
        ' allLen:' +
        allLen.toString();
    print(testString);

    allTheMessages.forEach((element) {
      print("all: ${element['content']}");
    });
    //  print("snapMessages: ${snapshotMessages.fore}");
    //  print("localMessages: ${localMessages.toString()}");
    //  print("allTheMessages: ${allTheMessages.toString()}");

    if (snapLen == 0) {
      return;
    } else if ((snapLen + localLen) - allLen == 1) {
      // case: One message behind the live data (difference in length = 1)
      var timeSent;
      var lastMessageSent = snapshotMessages.first;
      if (lastMessageSent.metadata.hasPendingWrites) {
        return;
      } else {
        timeSent = lastMessageSent['timeSent'];
        print("timesent $timeSent");
      }
      futureLastMessageSavedLocallyTime = lastMessageSent['timeSent'];
      return allTheMessages.add(Message(
              color: lastMessageSent['color'],
              content: lastMessageSent['content'],
              timeSent: timeSent)
          .toJson());
    } else if ((snapLen + localLen) - allLen == 0) {
      // case: up to date with live data.
      // swap the last message with the newest message, (this happens because of FieldValue.TimeStamp causes the method to be called twice)
      var lastMessageSent = snapshotMessages.first;
      var timeSent;
      if (lastMessageSent.metadata.hasPendingWrites) {
        return;
      } else {
        timeSent = lastMessageSent['timeSent'];
        print("timesent $timeSent");
      }
      futureLastMessageSavedLocallyTime = lastMessageSent['timeSent'];
      allTheMessages[allLen - 1] = (Message(
              color: lastMessageSent['color'],
              content: lastMessageSent['content'],
              timeSent: timeSent))
          .toJson();
    } else {
      // case: several messages behind.
      allTheMessages = [];
      for (var message in localMessages.reversed) {
        Timestamp timeSent = message['timeSent'];
        String encodedTimeStamp = timeSent.toDate().toIso8601String();
        Map<String, dynamic> copyedMessage = Map<String, dynamic>();
        message.forEach((key, value) {
          print(value);
          if (key == 'timeSent') {
            copyedMessage[key] = encodedTimeStamp;
          } else {
            copyedMessage[key] = value;
          }
        });
        allTheMessages.add(copyedMessage);
        allTheMessages.last['timeSent'] = encodedTimeStamp;
      }
      for (var message in snapshotMessages.reversed) {
        if (messageCounter == 0) return;
        var timeSent;

        if (message.metadata.hasPendingWrites) {
          return;
        } else {
          timeSent = message['timeSent'];
        }

        allTheMessages.add(Message(
                color: message['color'],
                content: message['content'],
                timeSent: timeSent)
            .toJson());
      }
    }
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
      if (newColorsStatus[colorName] != null &&
          newColorsStatus[colorName] !=
              Provider.of<AppData>(context, listen: false).currentUserID) {
        String newColorName;
        // loop through the status until you find a color that hasn't been assigned to anyone
        newColorsStatus.forEach((name, id) {
          if (id == null) {
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

  void listenToChatroomChanges() {
    timeLastLeftListener = firestore
        .collection('chatRooms')
        .document(widget.salfhID)
        .snapshots()
        .listen((event) {
      Map<String, Timestamp> newLastLeftStatus =
          Map<String, Timestamp>.from(event.data['lastLeftStatus']);
      // print("hereeee${event.data}");
      if (!mapEquals(lastLeftStatus, newLastLeftStatus)) {
        setState(() {
          lastLeftStatus = newLastLeftStatus;
        });
      }

      if (!mapEquals(typingStatus, event.data['typingStatus'])) {
        setState(() {
          typingStatus = event.data['typingStatus'];
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
    if (mounted)
      setState(() {
        joining = false;
      });

    return joined;
  }

  // sends the message only if the user successfully joined the salfh
  /// the bool state 'joining' is used to render the joining state on the ui
  void _onSubmit() async {
    print('onSubmit');
    setState(() {
      sending = true;
    });
    print('onSubmit2');
    if (inputMessage == "" || inputMessage == null) {
      sending = false;
      return;
    }
    print(isInSalfh);
    if (isInSalfh) {
      sendMessage();
      _changeTypingTo(false);
    } else {
      bool joined;
      print("here?@");
      joined = await _joinSalfh();
      if (joined) {
        setState(() {
          isInSalfh = true;
        });
        sendMessage();
        _changeTypingTo(false);
      }
    }
    setState(() {
      inputMessage = '';
    });
  }

  void sendMessage() async {
    bool success = await addMessage(inputMessage, colorName, widget.salfhID,
        Provider.of<AppData>(context, listen: false).currentUserID);
    if (success) {
      //TODO: display the message on screen only when it's been written to the database
      messageCounter++;

      messageController.clear();
    }

    if (mounted)
      setState(() {
        sending = false;
      });
  }

  Future<void> setUserTimeLeft() async {
    final firestore = Firestore.instance;
    SharedPreferences.getInstance().then((value) =>
        value.setString(widget.salfhID, DateTime.now().toIso8601String()));
    await firestore.collection("chatRooms").document(widget.salfhID).setData({
      'lastLeftStatus': {
        colorName: DateTime.now(),
      }
    }, merge: true);

    // // using transactions
    // final ref = firestore.collection('chatRooms').document(widget.salfhID);
    // await firestore.runTransaction((transaction) async {
    //   final snapshot = await transaction.get(ref);
    //   if (snapshot.exists) {
    //     if (DateTime.now().compareTo(snapshot.data[colorName]) < 0) {
    //       transaction.update(ref, {colorName: DateTime.now()});
    //     }
    //   }
    // });

    // changed this so that it rewrites the one field instead of the whole map
    // await firestore.collection("Swalf").document(widget.salfhID).setData({
    //   'colorsStatus': {
    //     colorName: {
    //       'isInChatRoom': false,
    //     }
    //   }
    // }, merge: true);
  }

  setTimeLeftInfinity() async {
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      final firestore = Firestore.instance;
      await firestore.collection("chatRooms").document(widget.salfhID).setData({
        'lastLeftStatus': {
          colorName: DateTime.now().add(
            Duration(days: 3650),
          ), // when the user is in, set the time he last left to infinity.
        },
      }, merge: true);
    }

    // /// using transactions
    // final ref = firestore.collection('chatRooms').document(widget.salfhID);
    // await firestore.runTransaction((transaction) async {
    //   final snapshot = await transaction.get(ref);
    //   if (snapshot.exists) {
    //     if (DateTime.now()
    //             .add(Duration(days: 3000))
    //             .compareTo(snapshot.data[colorName]) >
    //         0) {
    //       await transaction.update(
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

  void _changeTypingTo(bool isTyping) {
    firestore.collection('chatRooms').document(widget.salfhID).setData({
      'typingStatus': {
        colorName: isTyping,
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

  Future<void> setLocalStorage() async {
    if (futureLastMessageSavedLocallyTime != null) {
      await storage.ready;
      storage.setItem('local_messages', allTheMessages.reversed.toList());
      print("before saving $futureLastMessageSavedLocallyTime");
      {
        storage.setItem('last_message_time',
            futureLastMessageSavedLocallyTime.toDate().toIso8601String());
      }
    }
  }

  void _onClose() async {
    setUserTimeLeft();
    colorStatusListener.cancel();
    timeLastLeftListener.cancel();
    if (inputMessage.isNotEmpty) {
      inputMessage = '';
      _changeTypingTo(false);
    }
    if (isInSalfh) setLocalStorage();
  }

  @override
  void dispose() {
    _onClose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('Current state: $state');
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setUserTimeLeft();
      _changeTypingTo(false);
    }
    if (state == AppLifecycleState.resumed) {
      setTimeLeftInfinity();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backGround = Colors.white;
    Color currentColor = kOurColors[colorName];
    //////////////////// hot reload to add message
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueAccent[50],
        endDrawer: ChatScreenDrawer(
            title: widget.title,
            adminID: widget.adminID,
            colorsStatus: colorsStatus,
            color: colorName,
            salfhID: widget.salfhID),
        endDrawerEnableOpenDragGesture: isInSalfh,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection("chatRooms")
                        .document(widget.salfhID)
                        .collection('messages')
                        .orderBy('timeSent')
                        .startAfter([lastMessageSavedLocally]).snapshots(),
                    builder: (context, snapshot) {
                      print("lastMessageTime $lastMessageSavedLocally");

                      //TODO: display the message on sc reen only when it's been written to the database
                      if (!snapshot.hasData || lastLeftStatus == null) {
                        return LoadingWidget("");
                      }

                      final messages = snapshot.data.documents.reversed;
                      List<DocumentSnapshot> snapshotMessages =
                          messages.toList();
                      Set<String> alreadyRead = Set<String>();
                      List<MessageTile> messageTiles = [];

                      populateAllMessages(snapshotMessages, localMessages);

                      for (int i = 0;
                          i < snapshotMessages.length + localMessages.length;
                          i++) {
                        var message;
                        bool isSending;
                        if (i < snapshotMessages.length) {
                          message = snapshotMessages[i];
                          isSending = message.metadata.hasPendingWrites;
                        } else {
                          message = localMessages[i - snapshotMessages.length];
                          print('message 2 $message');
                          isSending = false;
                        }

                        List<String> readColors = [];
                        lastLeftStatus.forEach((color, lastLeft) {
                          var estimateTimeSent;
                          if (message is DocumentSnapshot &&
                              message.metadata.hasPendingWrites) {
                            estimateTimeSent = Timestamp.now();
                          } else {
                            // print(message.keys);

                            estimateTimeSent = message['timeSent'];
                          }
                          if (message['color'] != color &&
                              !alreadyRead.contains(color) &&
                              lastLeft.compareTo(estimateTimeSent) >= 0) {
                            readColors.add(color);
                            alreadyRead.add(color);
                          }
                        });
                        print('Stream');

                        messageTiles.add(MessageTile(
                          color: message['color'],
                          message: message["content"],
                          fromUser: message['color'] == colorName,
                          readColors: readColors,
                          isSending: isSending,

                          //
                          // add stuff here when you update messageTile
                          // time: message["time"],
                          //
                        ));
                      }
                      print('after');
                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
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
                        child: TypingWidgetRow(typingStatus: typingStatus)),
                  ),
                  ChatScreenAppBar(isInSalfh: isInSalfh, color: colorName),
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
      ),
    );
  }
}
