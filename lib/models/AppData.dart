import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/Services/ValidFirebaseStringConverter.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/components/TagTile.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Tag.dart';
import 'package:solif/models/Salfh.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:localstorage/localstorage.dart';

class AppData with ChangeNotifier {
  FirebaseUser currentUser;
  List<SalfhTile> usersSalfhTiles;
  List<SalfhTile> publicSalfhTiles;
  List<TagTile> tagsSavedLocally = [];
  bool isTagslLoaded = false;
  String _searchTag;
  final Firestore firestore = Firestore.instance;
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
    prefs = await SharedPreferences.getInstance();
    await auth.signOut();
    await loadUser();
    listenForNewUserSwalf();
    loadTiles();
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

    final user = await auth.currentUser();
    if (user != null) {
      currentUser = user;
    } else {
      final res = await auth.signInAnonymously();
      if (res != null) {
        currentUser = res.user;
        await firestore
            .collection('users')
            .document(currentUserID)
            .setData({'userSwalf': {}, 'id': currentUserID});
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

  setUsersSalfhTiles(List<SalfhTile> salfhTiles) {
    usersSalfhTiles = salfhTiles;
    notifyListeners();
  }

  setPublicSalfhTiles(List<SalfhTile> salfhTiles) {
    publicSalfhTiles = salfhTiles;
    notifyListeners();
  }

  reloadUsersSalfhTiles() async {
    usersSalfhTiles = [];
    notifyListeners();
    usersSalfhTiles = await getUsersChatScreenTiles(currentUserID);

    notifyListeners();
  }

  listenForNewUserSwalf() {
    firestore
        .collection('users')
        .document(currentUserID)
        .snapshots()
        .listen((snapshot) {
      reloadUsersSalfhTiles();
    });
  }

  reloadPublicSalfhTiles() async {
    publicSalfhTiles = [];
    notifyListeners();
    publicSalfhTiles =
        await getPublicChatScreenTiles(currentUserID, tag: _searchTag);
    notifyListeners();
  }

  loadNextPublicSalfhTiles() async {
    if (nextPublicTiles == null) return;
    final salfhDocs = await nextPublicTiles.getDocuments();
    List<SalfhTile> newSalfhTiles = [];
    Random random = Random();
    for (var salfh in salfhDocs.documents) {
      if (salfh['adminID'] != currentUserID) {
        bool isFull = true;
        salfh['colorsStatus'].forEach((color, id) {
          if (id == null) isFull = false;
        });
        if (!isFull)
          newSalfhTiles.add(SalfhTile(
            // color now generated in SalfhTile
            colorsStatus: salfh['colorsStatus'],
            title: salfh['title'],
            adminID: salfh['adminID'],

            id: salfh.documentID,
            tags: salfh['tags'] ?? [], //////// TODO: remove null checking
          ));
      }
    }
    newSalfhTiles.insertAll(0, publicSalfhTiles);
    if (salfhDocs.documents.isNotEmpty) {
      final Timestamp lastVisibleSalfhTime =
          salfhDocs.documents[salfhDocs.documents.length - 1]['timeCreated'];
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

  void deleteTag(String tag) {
    tagsSavedLocally.removeWhere((element) => element.tagName == tag);
    Firestore.instance
        .collection('users')
        .document(currentUserID)
        .collection('userTags')
        .document(tag)
        .delete();
    tag = ValidFireBaseStringConverter.convertString(tag);
    fcm.unsubscribeFromTopic("${tag}TAG");

    tagsSavedLocally = tagsSavedLocally.map((e) => e).toList();

    notifyListeners();
  }

  void addTag(String tag) {
    if (tag == null || tag == '') return;
    tagsSavedLocally.add(TagTile(
      tagName: tag,
      // onCancelPressed: deleteTag,)
    ));
    Firestore.instance
        .collection('users')
        .document(currentUserID)
        .collection('userTags')
        .document(tag)
        .setData({'tagName': tag, 'timeAdded': DateTime.now()});
    tag = ValidFireBaseStringConverter.convertString(tag);
    print(tag); 
    fcm.subscribeToTopic(
        "${tag}TAG"); // without  an ending ID for tag topic, a salfh topic and a tag topic could have the same name. two topics same name = bad.

    tagsSavedLocally = tagsSavedLocally.map((e) => e).toList();
    notifyListeners();
  }

  bool isTagsLoadedLocally() {
    return isTagslLoaded;
  }

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
