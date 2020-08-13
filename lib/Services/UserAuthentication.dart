import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'FirebaseServices.dart';

class UserAuthentication{

  static String currentUserID; 
  static FirebaseUser currentUser;

  
  static Future<void> loadInUser() async {

    final auth = FirebaseAuth.instance;
    final user = await auth.currentUser();
    final fcm = FirebaseMessaging();    
    
    
    if (user != null) {
      currentUser = user;
      currentUserID = currentUser.uid;
    } else {
      final res = await auth.signInAnonymously();
      if (res != null) {
        currentUser = res.user;
        currentUserID = currentUser.uid;
        await firestore
            .collection('users')
            .document(currentUserID)
            .setData({'userSwalf': {}, 'id': currentUserID});
        fcm.subscribeToTopic(currentUserID);
      }
    }
  }

}