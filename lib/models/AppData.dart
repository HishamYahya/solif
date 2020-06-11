import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/SalfhTile.dart';

class AppData with ChangeNotifier {
  String currentUserID;
  List<SalfhTile> usersSalfhTiles;
  List<SalfhTile> publicSalfhTiles;
  final Firestore firestore = Firestore.instance;

  AppData() {
    currentUserID = "00user";
    notifyListeners();
    loadTiles();
  }

  ///// if list is null then it hasn't been loaded yet (happens only once)

  isUsersTilesLoaded() {
    return usersSalfhTiles != null;
  }

  isPublicTilesLoaded() {
    return publicSalfhTiles != null;
  }

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
