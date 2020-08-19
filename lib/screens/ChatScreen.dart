import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/components/ChatInputBox.dart';
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
  List<DocumentSnapshot> snapshotMessages = [];
  List<Map<String, dynamic>> allTheMessages =
      []; // messages to be written to the storage.
  DateTime timeofLastMessageSavedLocally = DateTime(2030);
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
    storage = new LocalStorage(widget.salfhID + '.json'); //  sqlite plan b

    print('testing order');

    widget.colorsStatus.forEach((name, id) {
      if (id == userID)
        setState(() {
          isInSalfh = true;
        });
    });

    loadLocalStorageMessages();

    listenToChatroomChanges();
    listenToColorStatusChanges();

    super.initState();
  }

  Future<void> loadLocalStorageMessages() async {
    bool isReady = await storage.ready;
    print('isReady:$isReady');

    List<dynamic> storedMessages = storage.getItem('local_messages') ?? [];

    print("local items length ${storedMessages.length}");
    storedMessages.forEach((element) {
      if (element['timeSent'] is String) {
        element['timeSent'] =
            Timestamp.fromDate(DateTime.parse(element['timeSent']));
      }

      localMessages.add(element);
    });

    // allTheMessages.addAll(storedMessages);

    String stringFormatedTime = storage.getItem('last_message_time') ??
        DateTime(2010)
            .toIso8601String(); // default value last messages saved in 2010.

    timeofLastMessageSavedLocally = DateTime.parse(stringFormatedTime);

    // uncomment below to check the consistency of the local data with the server data.

    // final testDocs =await firestore.collection('chatRooms').document(widget.salfhID).collection('messages').orderBy('timeSent').getDocuments();
    // final testSnapshots = testDocs.documents.toList();

    // int cacheCounter = 0;

    // bool isEqual = true;
    // print('testsnapshot length ${testSnapshots.length}');
    // for (int i=0;i<localMessages.length;i++){
    //   print(i);
    //   if(testSnapshots[i].metadata.isFromCache){
    //     cacheCounter++;
    //   }
    //   print("${testSnapshots[i]['timeSent']} == ${localMessages[localMessages.length-i-1]['timeSent']} ");
    //   isEqual &= (localMessages[localMessages.length-i-1]['timeSent'] == testSnapshots[i]['timeSent']);
    //   // if(!isEqual) break;
    // }
    // print('isEqual $isEqual');
    // print('cache counter:  $cacheCounter');
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

    Timestamp lastMessageSentTime =
        Timestamp.fromDate(timeofLastMessageSavedLocally);
    allTheMessages = [];
    for (var message in localMessages.reversed) {
      allTheMessages.add(Message(
              color: message['color'],
              content: message['content'],
              timeSent: message['timeSent'])
          .toJson());
    }
    for (var message in snapshotMessages.reversed) {
      // if (messageCounter == 0) return;
      if (message.metadata.hasPendingWrites) {
        continue;
      }

      bool isCurrentMessageGreater =
          lastMessageSentTime.compareTo(message['timeSent']) < 0;
      if (isCurrentMessageGreater)
        futureLastMessageSavedLocallyTime = message['timeSent'];

      allTheMessages.add(Message(
              color: message['color'],
              content: message['content'],
              timeSent: message['timeSent'])
          .toJson());
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
      if (joined && mounted) {
        setState(() {
          isInSalfh = true;
        });
        sendMessage();
        _changeTypingTo(false);
      }
    }
    if (mounted) {
      setState(() {
        inputMessage = '';
      });
    }
    ;
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

  void _onClose() async {
    print(storage.toString());
    setUserTimeLeft();
    colorStatusListener.cancel();
    timeLastLeftListener.cancel();
    if (inputMessage.isNotEmpty) {
      inputMessage = '';
      _changeTypingTo(false);
    }
    if (isInSalfh) {
      populateAllMessages(snapshotMessages, localMessages);
      print('Saving messages...');
      await setLocalStorage(
          allTheMessages, futureLastMessageSavedLocallyTime, storage);
    }
    print('Done saving!');
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
    Color currentColor = kOurColors[colorName];
    //////////////////// hot reload to add message

    return WillPopScope(
      onWillPop: () => isInSalfh
          ? setLocalStorage(
              allTheMessages, futureLastMessageSavedLocallyTime, storage)
          : {},
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: Colors.grey[500],
              ),
              Expanded(child: TypingWidgetRow(typingStatus: typingStatus)),
              isInSalfh
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.view_stream),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        color: currentColor,
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          actions: <Widget>[Container()],
        ),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("chatRooms")
                    .document(widget.salfhID)
                    .collection('messages')
                    .orderBy('timeSent')
                    .startAfter([timeofLastMessageSavedLocally]).snapshots(),
                builder: (context, snapshot) {
                  // print("lastMessageTime $lastMessageSavedLocally");
                  int cacheCounter = 0;

                  //TODO: display the message on sc reen only when it's been written to the database
                  if (!snapshot.hasData || lastLeftStatus == null) {
                    return LoadingWidget("");
                  }

                  final messages = snapshot.data.documents.reversed;
                  snapshotMessages = messages
                      .toList(); // this could be expensive in the long run, but easy to use.
                  // note to self: Use iterator instead if ever preformance issues occur.
                  Set<String> alreadyRead = Set<String>();
                  List<MessageTile> messageTiles = [];

                  // populateAllMessages(snapshotMessages, localMessages); //

                  for (int i = 0;
                      i < snapshotMessages.length + localMessages.length;
                      i++) {
                    var message;
                    bool isSending;
                    if (i < snapshotMessages.length) {
                      // snapshot message

                      message = snapshotMessages[i];
                      cacheCounter++;
                      isSending = message.metadata.hasPendingWrites;
                    } else {
                      // local message
                      message = localMessages[i - snapshotMessages.length];
                      isSending = false;
                    }
                    // print(colorsStatus);

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
                          lastLeft.compareTo(estimateTimeSent) >= 0 &&
                          colorsStatus[color] != null) {
                        readColors.add(color);
                        alreadyRead.add(color);
                      }
                    });
                    // print('Stream');

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
                  //  print('after');
                  print('messages from cache $cacheCounter');
                  return ListView.builder(
                    reverse: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    itemCount: messageTiles.length,
                    itemBuilder: (context, index) {
                      return messageTiles[index];
                    },
                  );
                },
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
