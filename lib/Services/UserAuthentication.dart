import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'FirebaseServices.dart';

class UserAuthentication {
  static String currentUserID;
  static User currentUser;

  static Future<void> loadInUser() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
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
            .doc(currentUserID)
            .set({'userSwalf': {}, 'id': currentUserID});
        fcm.subscribeToTopic(currentUserID);
      }
    }
  }
}
