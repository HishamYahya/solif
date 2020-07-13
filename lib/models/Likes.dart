import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:solif/models/AppData.dart';

final firestore = Firestore.instance;
final deleteKey = FieldValue.delete();

likeUser(String currentUserID, String likedUserID){


  firestore.collection('likes').document(likedUserID).setData({
    'usersVote':{
      currentUserID: 'like'
    }
  },merge: true);
  
}
unLikeUser(String currentUserID, String likedUserID){


  firestore.collection('likes').document(likedUserID).setData({
        'usersVote':{
      currentUserID: deleteKey
    }
  },merge: true);
  
}


dislikeUser(String currentUserID, String likedUserID){


  firestore.collection('likes').document(likedUserID).setData({
    'usersVote':{
      currentUserID: 'dislike'
    }
  },merge: true);
  
}
unDislikeUser(String currentUserID, String likedUserID){
  unLikeUser(currentUserID, likedUserID); 
}