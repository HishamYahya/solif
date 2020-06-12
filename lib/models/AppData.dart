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
    publicSalfhTiles = await getPublicChatScreenTiles();
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
}
