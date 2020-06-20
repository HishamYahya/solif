import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/SalfhTile.dart';

class AppData with ChangeNotifier {
  String currentUserID;
  List<SalfhTile> usersSalfhTiles;
  List<SalfhTile> publicSalfhTiles;
  final Firestore firestore = Firestore.instance;
  static Query nextPublicTiles;

  //local saved data
  SharedPreferences prefs;

  AppData() {
    init();
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    await loadUser();
    loadTiles();
  }

  loadUser() async {
    String key = 'userID';
    String userID = prefs.getString(key);

    // create new user every restart for testing
    await prefs.remove(key);
    userID = prefs.getString(key);
    if (userID != null) {
      currentUserID = userID;
    } else {
      final ref = await firestore.collection('users').add({'userSwalf': {}});
      userID = ref.documentID;
      print(userID);
      prefs.setString(key, userID);
      currentUserID = userID;
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
    publicSalfhTiles = await getPublicChatScreenTiles(currentUserID);
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
    usersSalfhTiles = await getUsersChatScreenTiles(currentUserID);
    notifyListeners();
  }

  reloadPublicSalfhTiles() async {
    publicSalfhTiles = await getPublicChatScreenTiles(currentUserID);
    notifyListeners();
  }

  loadNextPublicSalfhTiles() async {
    final salfhDocs = await nextPublicTiles.getDocuments();
    List<SalfhTile> newSalfhTiles = [];
    Random random = Random();
    for (var salfh in salfhDocs.documents) {
      if (salfh['creatorID'] != currentUserID) {
        bool isFull = true;
        salfh['colorsStatus'].forEach((name, statusMap) {
          if (statusMap['userID'] == null) isFull = false;
        });
        if (!isFull)
          newSalfhTiles.add(SalfhTile(
            category: salfh["category"],
            // color now generated in SalfhTile
            colorsStatus: salfh['colorsStatus'],
            title: salfh['title'],
            id: salfh.documentID,
          ));
      }
    }
    newSalfhTiles.insertAll(0, publicSalfhTiles);

    final Timestamp lastVisibleSalfhTime =
        salfhDocs.documents[salfhDocs.documents.length - 1]['timeCreated'];
    // next batch starts after the last document
    nextPublicTiles = firestore
        .collection('Swalf')
        .orderBy('timeCreated', descending: true)
        .startAfter([lastVisibleSalfhTime]).limit(2);

    publicSalfhTiles = newSalfhTiles;
    notifyListeners();
  }
}
