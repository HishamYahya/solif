import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/AppData.dart';

import '../constants.dart';

final firestore = Firestore.instance;

Future<List<SalfhTile>> getUsersChatScreenTiles(String userID) async  {
  try{
  int x = 1;
  final salfhDoc = await firestore.collection('users').document(userID).get();
  List<SalfhTile> salfhTiles = [];
  Map<String, dynamic> userSwalf = await salfhDoc['userSwalf'];
  if (userSwalf == null) return [];
  for (var entry in userSwalf.entries) {
    var currentSalfh =
        await firestore.collection('Swalf').document(entry.key).get();

    salfhTiles.add(SalfhTile(
      colorsStatus: currentSalfh['colorsStatus'],
      title: currentSalfh['title'],
      id: currentSalfh.documentID,
      adminID: currentSalfh['adminID'],
      tags: currentSalfh['tags'] ?? [], //////// TODO: remove null checking
      lastMessageSent: currentSalfh['lastMessageSent'],
    ));
  }

  salfhTiles.sort((a, b) {
    return b.lastMessageSentTime
        .compareTo(a.lastMessageSentTime); // sort using datetime comparator.
  });

  return salfhTiles;
   }on AuthException catch(e){
     print(e.toString());
     throw("Permission Denied");
  }catch(e){
    print(e.toString()); 
    throw('error');
  }
}

Future<List<SalfhTile>> getPublicChatScreenTiles(String userID,
    {String tag}) async {
  // final salfhDocs = await firestore
  //     .collection('Swalf')
  //     .orderBy('timeCreated', descending: true)
  //     .getDocuments();

  // List<SalfhTile> salfhTiles = [];
  // Random random = Random();
  // for (var salfh in salfhDocs.documents) {
  //   if (salfh['adminID'] != userID) {
  //     bool isFull = true;
  //     salfh['colorsStatus'].forEach((name, statusMap) {
  //       if (statusMap['userID'] == null) isFull = false;
  //     });
  //     if (!isFull)
  //       salfhTiles.add(SalfhTile(
  //         category: salfh["category"],
  //         // color now generated in SalfhTile
  //         colorsStatus: salfh['colorsStatus'],
  //         title: salfh['title'],
  //         id: salfh.documentID,
  //       ));
  //   }
  // }
  // return salfhTiles;
  final first = firestore
      .collection('Swalf')
      .where('tags', arrayContains: tag)
      .where('visible', isEqualTo: true)
      .orderBy('timeCreated', descending: true)
      .limit(kMinimumSalfhTiles);
  final salfhDocs = await first.getDocuments();
  List<SalfhTile> salfhTiles = [];
  Random random = Random();
  for (var salfh in salfhDocs.documents) {
    if (salfh['adminID'] != userID) {
      bool isFull = true;
      salfh['colorsStatus'].forEach((name, id) {
        if (id == null) isFull = false;
      });
      if (!isFull)
        salfhTiles.add(SalfhTile(
          // color now generated in SalfhTile
          colorsStatus: salfh['colorsStatus'],
          adminID: salfh['adminID'],
          title: salfh['title'],
          id: salfh.documentID,
          tags: salfh['tags'] ?? [],
          lastMessageSent:
              salfh['lastMessageSent'], //////// TODO: remove null checking
        ));
    }
  }
  if (salfhTiles.isNotEmpty) {
    final Timestamp lastVisibleSalfhTime =
        salfhDocs.documents[salfhDocs.documents.length - 1]['timeCreated'];
    // next batch starts after the last document
    AppData.nextPublicTiles = firestore
        .collection('Swalf')
        .where('tags', arrayContains: tag)
        .where('visible', isEqualTo: true)
        .orderBy('timeCreated', descending: true)
        .startAfter([lastVisibleSalfhTime]).limit(kMinimumSalfhTiles);
  }

  return salfhTiles;
}

getSalfh(salfhID) async {
  final ref = await firestore.collection('Swalf').document(salfhID).get();
  if (ref.exists) {
    return ref.data;
  }
  return null;
}

// tags = {
//   "tag1": count1,
//   'tag2': count2,
//   'tag3': count3,
// }
