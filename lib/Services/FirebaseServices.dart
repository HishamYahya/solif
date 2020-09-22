import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/AppData.dart';

import '../constants.dart';

final firestore = Firestore.instance;

Future<List<SalfhTile>> getUsersChatScreenTiles(String userID) async {
  try {
    int x = 1;
    final salfhDoc = await firestore.collection('users').doc(userID).get();
    Map<String, dynamic> salfhMap = salfhDoc.data();
    List<SalfhTile> salfhTiles = [];
    Map<String, dynamic> userSwalf = salfhMap['userSwalf'];
    if (userSwalf == null) return [];
    for (var entry in userSwalf.entries) {
      var currentSalfh =
          await firestore.collection('Swalf').doc(entry.key).get();
      Map<String, dynamic> currentSalfhMap = currentSalfh.data();

      salfhTiles.add(SalfhTile(
        key: UniqueKey(),
        colorsStatus: currentSalfhMap['colorsStatus'],
        title: currentSalfhMap['title'],
        id: currentSalfh.id,
        adminID: currentSalfhMap['adminID'],
        tags: currentSalfhMap['tags'] ?? [], //////// TODO: remove null checking
        lastMessageSent: currentSalfhMap['lastMessageSent'],
      ));
    }

    salfhTiles.sort((a, b) {
      return b.lastMessageSentTime
          .compareTo(a.lastMessageSentTime); // sort using datetime comparator.
    });

    return salfhTiles;
  } on FirebaseAuthException catch (e) {
    print(e.toString());
    throw ("Permission Denied");
  } catch (e) {
    print(e.toString());
    throw ('error');
  }
}

Future<List<SalfhTile>> getPublicChatScreenTiles(String userID,
    {String tag}) async {
  // final salfhMaps = await firestore
  //     .collection('Swalf')
  //     .orderBy('timeCreated', descending: true)
  //     .getDocuments();

  // List<SalfhTile> salfhTiles = [];
  // Random random = Random();
  // for (var salfh in salfhMaps.documents) {
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
  final salfhMaps = await first.get();
  List<SalfhTile> salfhTiles = [];
  Random random = Random();
  for (var salfhDoc in salfhMaps.docs) {
    Map<String, dynamic> salfh = salfhDoc.data();
    if (salfh['adminID'] != userID) {
      bool isFull = true;
      salfh['colorsStatus'].forEach((name, id) {
        if (id == null) isFull = false;
      });
      if (!isFull)
        salfhTiles.add(SalfhTile(
          // color now generated in SalfhTile
          key: UniqueKey(),
          colorsStatus: salfh['colorsStatus'],
          adminID: salfh['adminID'],
          title: salfh['title'],
          id: salfhDoc.id,
          tags: salfh['tags'] ?? [],
          lastMessageSent:
              salfh['lastMessageSent'], //////// TODO: remove null checking
        ));
    }
  }
  if (salfhTiles.isNotEmpty) {
    final Timestamp lastVisibleSalfhTime =
        salfhMaps.docs[salfhMaps.docs.length - 1].data()['timeCreated'];
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
