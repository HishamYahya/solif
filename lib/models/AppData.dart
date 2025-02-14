import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/Services/ValidFirebaseStringConverter.dart';
import 'package:solif/components/NotificationTile.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/components/TagChip.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Notification.dart';
import 'package:solif/models/Tag.dart';
import 'package:solif/models/Salfh.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:localstorage/localstorage.dart';

class AppData with ChangeNotifier {
  User currentUser;
  List<SalfhTile> usersSalfhTiles;
  List<SalfhTile> publicSalfhTiles;
  List<NotificationTile> notificationTiles;
  List<String> mutedSwalf = [];
  bool isTagslLoaded = false;
  String _searchTag;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final fcm = FirebaseMessaging();
  final auth = FirebaseAuth.instance;

  var messsagesDataBase;

  static Query nextPublicTiles;

  //local saved data
  SharedPreferences prefs;
  //
  //

  get currentUserID {
    if (currentUser != null) return currentUser.uid;
    return null;
  }

  set searchTag(String tag) {
    _searchTag = tag;
    reloadPublicSalfhTiles();
  }

  get searchTag {
    return _searchTag;
  }

  AppData() {
    // print('local storage test');

    // LocalStorage ls = LocalStorage('test.json');
    // ls.ready.then((value) => ls.setItem('timeStamp', [Timestamp(10,20)]));
    // var testTimeStamp = ls.getItem('timeStamp');
    // print(testTimeStamp.runtimeType);
    // print(testTimeStamp);

    // print('here');
    // leaveSalfh(salfhID:
    // "zFX6VZ7czRIdAirTqaZB",userColor: 'green',userID:"LX2Cw01JQlMSxPUroH37");

    // // test();
    // // var checking = firestore
    // //     .collection('Swalf')
    // //     .document('adDA8QSgpOEfNzoLZgm2')
    // //     .get()
    //     .then((value) {
    //   print(value['lastMessageSent'] == null);
    // });

    init();
    // List<String> tags = [];
    // List<String> chars = ['a','b','c','d'];
    // for(int i=0;i<chars.length*3;i++){
    //    for(int j=0;j<chars.length*6;j++){
    //      for(int k=0;k<chars.length*8;k++){
    //      String temp = chars[i%chars.length] + chars[j%chars.length] + chars[k%chars.length];
    //      tags.add(temp);
    //      }
    //    }
    // }
    // incrementTags(tags);

    // List<String> chars = ['a', 'b', 'c', 'd'];
    // List<String> tags = [];
    // for (int i = 0; i < chars.length; i++) {
    //   for (int j = 0; j < chars.length; j++) {
    //     for (int k = 0; k < chars.length; k++) {
    //       String temp = chars[i] + chars[j] + chars[k];
    //       tags.add(temp);
    //     }
    //   }
    // }
    // for (int i = 0; i < tags.length; i++) {
    //   firestore.collection('tags').document(tags[i]).setData({
    //     'tagName': tags[i],
    //     'tagCounter': tags.length - i,
    //     'searchKeys': stringKeys(tags[i])
    //   });
    // }
  }

  List<String> stringKeys(String tag) {
    List<String> keys = List();
    for (int i = 0; i < tag.length; i++) {
      keys.add(tag.substring(0, i + 1));
    }
    return keys;
  }

  init() async {
    // await auth.signOut();
    await loadUser();
    prefs = await SharedPreferences.getInstance();
    // await auth.signOut();

    listenForNewUserSwalf();
    listenForNewNotifications();
    loadTiles();
  }

  void listenForNewNotifications() {
    firestore
        .collection('users')
        .doc(currentUserID)
        .collection('notifications')
        .orderBy('timeSent')
        .snapshots()
        .listen((snapshot) {
      notificationTiles = generateNotificationTiles(snapshot.docs);
      print(notificationTiles);
      notifyListeners();
    });
  }

  reset() async {
    await auth.signOut();
    init();
  }

  Future<void> loadUser() async {
    // String key = 'userID';
    // String userID = prefs.getString(key);
    // prefs.setString('salfhID', DateTime.now().toIso8601String());

    // // create new user every restart for testing
    // await prefs.remove(key);
    // userID = prefs.getString(key);
    // if (userID != null) {
    //   currentUserID = userID;
    // } else {
    //   final ref = await firestore.collection('users').add({'userSwalf': {}});
    //   userID = ref.documentID;
    //   print(userID);
    //   prefs.setString(key, userID);
    //   currentUserID = userID;
    //   fcm.subscribeToTopic(userID);

    // }
    // notifyListeners();

    final user = auth.currentUser;

    if (user != null) {
      currentUser = user;
    } else {
      final res = await auth.signInAnonymously();
      if (res != null) {
        currentUser = res.user;
        String token = await fcm.getToken();
        await firestore.collection('users').doc(currentUserID).set({
          'userSwalf': {},
          'id': currentUserID,
          'fcmToken': token,
          'mutedSwalf': [],
          'subscribedTags': [],
        });
        fcm.subscribeToTopic(currentUserID);
      }
    }
    notifyListeners();
  }

  isUsersTilesLoaded() {
    return usersSalfhTiles != null;
  }

  isPublicTilesLoaded() {
    return publicSalfhTiles != null;
  }

  ///// if list is null then it hasn't been loaded yet (happens only once)
  loadTiles() async {
    usersSalfhTiles = await getUsersChatScreenTiles(currentUserID);

    notifyListeners();
    publicSalfhTiles =
        await getPublicChatScreenTiles(currentUserID, tag: _searchTag);
    notifyListeners();
  }

  // setUsersSalfhTiles(List<SalfhTile> salfhTiles) {
  //   usersSalfhTiles = salfhTiles;
  //   notifyListeners();
  // }

  setPublicSalfhTiles(List<SalfhTile> salfhTiles) {
    publicSalfhTiles = salfhTiles;
    notifyListeners();
  }

  reloadUsersSalfhTiles() async {
    final newUsersSalfhTiles = await getUsersChatScreenTiles(currentUserID);
    usersSalfhTiles = [];
    notifyListeners();
    usersSalfhTiles = newUsersSalfhTiles;
    notifyListeners();
  }

  listenForNewUserSwalf() {
    firestore
        .collection('users')
        .doc(currentUserID)
        .snapshots()
        .listen((snapshot) {
      if (usersSalfhTiles == null ||
          snapshot.data()['userSwalf'].length != usersSalfhTiles.length)
        reloadUsersSalfhTiles();
      if (snapshot.data()['mutedSwalf'].length != mutedSwalf) {
        mutedSwalf = snapshot.data()['mutedSwalf'].cast<String>();
        notifyListeners();
      }
    });
  }

  reloadPublicSalfhTiles() async {
    final newPublicSalfhTiles =
        await getPublicChatScreenTiles(currentUserID, tag: _searchTag);
    // publicSalfhTiles = [];
    // notifyListeners();
    publicSalfhTiles = newPublicSalfhTiles;
    notifyListeners();
  }

  loadNextPublicSalfhTiles() async {
    if (nextPublicTiles == null) return;
    final salfhDocs = await nextPublicTiles.get();
    List<SalfhTile> newSalfhTiles = [];
    Random random = Random();
    for (var salfh in salfhDocs.docChanges) {
      Map<String, dynamic> salfhMap = salfh.doc.data();
      if (salfhMap['adminID'] != currentUserID) {
        bool isFull = true;
        salfhMap['colorsStatus'].forEach((color, id) {
          if (id == null) isFull = false;
        });
        if (!isFull)
          newSalfhTiles.add(SalfhTile(
            // color now generated in SalfhTile
            key: UniqueKey(),
            colorsStatus: salfhMap['colorsStatus'],
            title: salfhMap['title'],
            adminID: salfhMap['adminID'],
            id: salfh.doc.id,
            lastMessageSent: salfhMap['lastMessageSent'],
            tags: salfhMap['tags'] ?? [], //////// TODO: remove null checking
          ));
      }
    }
    newSalfhTiles.insertAll(0, publicSalfhTiles);
    if (salfhDocs.docs.isNotEmpty) {
      final Timestamp lastVisibleSalfhTime =
          salfhDocs.docs[salfhDocs.docs.length - 1].data()['timeCreated'];
      // next batch starts after the last document
      nextPublicTiles = firestore
          .collection('Swalf')
          .where('tags', arrayContains: _searchTag)
          .where('visible', isEqualTo: true)
          .orderBy('timeCreated', descending: true)
          .startAfter([lastVisibleSalfhTime]).limit(kMinimumSalfhTiles);
    }
    publicSalfhTiles = newSalfhTiles;
    notifyListeners();
  }

  // Future<void> test() async {
  //   print("Xd 2 $currentUserID");
  //   await firestore
  //       .collection("users")
  //       .document(currentUserID)
  //       .collection('userTags')
  //       .getDocuments()
  //       .then((value) {
  //     for (var doc in value.documents) {
  //       print("hetre23");
  //     }
  //   });
  // }

  // Future<void> trigger() async {
  //   print('triggered');
  //   final HttpsCallable testFunc = CloudFunctions.instance.getHttpsCallable(
  //     functionName: 'testFunc',
  //   );

  //   HttpsCallableResult resp = await testFunc.call();
  //   print(resp.data);

  //   // Firestore.instance
  //   //     .collection('Swalf')
  //   //     .document('zdR8kEGrOH208WKUU1kk')
  //   //     .collection('userColors')
  //   //     .document('userColors')
  //   //     .setData({'XD': 33333}, merge: true);
  // }
}
