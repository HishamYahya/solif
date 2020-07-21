import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:solif/models/AppData.dart';

final firestore = Firestore.instance;
final deleteKey = FieldValue.delete();

likeUser(String currentUserID, String likedUserID){
  print('like');
  firestore.collection('likes').document(likedUserID).setData({
    'usersVotes':{
      currentUserID: 'like',
      //'otherUserID': 'like'  --> PERMISSION_DENIED
    },
    // 'likes': 30 --> PERMISSION_DENIED
  },merge: true);
  
}
unLikeUser(String currentUserID, String likedUserID){
  print("unlike");


  firestore.collection('likes').document(likedUserID).setData({
        'usersVotes':{  
      currentUserID: deleteKey
    }
  },merge: true);
  
}


dislikeUser(String currentUserID, String likedUserID){

  print("dis");


  firestore.collection('likes').document(likedUserID).setData({
    'usersVotes':{
      currentUserID: 'dislike'
    }
  },merge: true);
  
}
unDislikeUser(String currentUserID, String likedUserID){
  print('unDis');
  unLikeUser(currentUserID, likedUserID); 
}