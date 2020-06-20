import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/screens/ChatScreen.dart';

class User {
  Map<String, String> userSwalf; // id => userColor

  User();
}

addSalfhToUser(String userID, String salfhID, String userColor) async {
  final firesotre = Firestore.instance;

  await firestore
      .collection('users')
      .document(userID)
      .setData(<String, dynamic>{
    'userSwalf': {salfhID: userColor}
  }, merge: true);
}
