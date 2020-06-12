import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solif/components/SalfhTile.dart';

import '../constants.dart';

final firestore = Firestore.instance;

Future<List<SalfhTile>> getUsersChatScreenTiles(String userID) async {
  int x = 1;
  final salfhDoc = await firestore.collection('users').document(userID).get();
  List<SalfhTile> salfhTiles = [];
  Map<String, dynamic> userSwalf = await salfhDoc['userSwalf'];
  if (userSwalf == null) return [];
  for (var entry in userSwalf.entries) {
    var currentSalfh =
        await firestore.collection('Swalf').document(entry.key).get();

    salfhTiles.add(SalfhTile(
      category: currentSalfh["category"],
      colorsStatus: currentSalfh['colorsStatus'],
      title: currentSalfh['title'],
      id: currentSalfh.documentID,
      lastMessageSentTime: (currentSalfh['lastMessageSentTime'] as Timestamp).toDate()
    ));
  }

  salfhTiles.sort((a,b){
    return b.lastMessageSentTime.compareTo(a.lastMessageSentTime);  // sort using datetime comparator. 
  });

  print(salfhTiles.length);
  return salfhTiles;
}

Future<List<SalfhTile>> getPublicChatScreenTiles() async {
  final salfhDocs = await firestore.collection('Swalf').orderBy('timeCreated',descending: true).getDocuments();

  List<SalfhTile> salfhTiles = [];
  Random random = Random();
  for (var salfh in salfhDocs.documents) {
    salfhTiles.add(SalfhTile(
      category: salfh["category"],
      // color now generated in SalfhTile
      colorsStatus: salfh['colorsStatus'],
      title: salfh['title'],
      id: salfh.documentID,
    ));
  }
  print(salfhTiles.length);
  return salfhTiles;
}

getSalfh(salfhID) async {
  final ref = await firestore.collection('Swalf').document(salfhID).get();
  print(ref);
  if (ref.exists) {
    return ref.data;
  }
  return null;
}
