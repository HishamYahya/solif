import 'package:cloud_firestore/cloud_firestore.dart';

class Tags {
  
  String tagName; 



  Tags(
    {
      this.tagName
    }
  );

  Map<String, dynamic> toMap() {
    return {
      "tagName": this.tagName
    };
  }

  
}

  void incrementTags(List<String> tags){

    final firestore = Firestore.instance;
    final increment = FieldValue.increment(1); 



    for(String tag in tags){
      firestore.collection('tags').document(tag).setData({
        'tagCounter': increment,
      },merge: true);
    }
  }