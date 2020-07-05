import 'package:cloud_firestore/cloud_firestore.dart';

class Tag {
  String tagName;

  Tag({this.tagName});

  Map<String, dynamic> toMap() {
    return {"tagName": this.tagName};
  }
} // for (int i = 0; i < tags.length; i++) {

// }

void incrementTags(List<String> tags) {
  final firestore = Firestore.instance;
  final increment = FieldValue.increment(1);

  for (String tag in tags) {
    firestore.collection('tags').document(tag).setData({
      'tagName': tag,
      'tagCounter': increment,
      'searchKeys': stringKeys(tag)
    }, merge: true);
  }
}

List<String> stringKeys(String tag) {
  List<String> keys = List();
  for (int i = 0; i < tag.length; i++) {
    keys.add(tag.substring(0, i + 1));
  }
  return keys;
}
