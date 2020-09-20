import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/screens/ChatScreen.dart';

final firestore = Firestore.instance;

class User {
  Map<String, String> userSwalf; // id => userColor

  User();
}

addSalfhToUser(String userID, String salfhID, String userColor) async {
  await firestore.collection('users').doc(userID).set(<String, dynamic>{
    'userSwalf': {salfhID: userColor}
  }, SetOptions(merge: true));
}

// deleteSalfhFromUser(String salfhID,String userID) async {
//   return firestore.collection('users').document(userID).setData({
//     'userSwalf': {
//       salfhID: FieldValue.delete(),
//     }
//   },merge: true);
// }

// addKarma({String userID,int amount}){

//   firestore.collection('users').document(userID).setData({
//     'karma': FieldValue.increment(amount)
//   },merge: true);
// }
