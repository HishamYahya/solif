import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/User.dart';
import 'package:solif/models/Tag.dart';

import '../constants.dart';

final firestore = Firestore.instance;

class Salfh {
  final Map<String, dynamic>
      colorsStatus; // Color: {"userID": id, "lastMessageRead":messageID, "isInChatRoom":bool}
  int maxUsers;
  String creatorID;
  String title;
  FieldValue timeCreated;
  Map lastMessageSent;
  List<String> tags;

  Salfh({
    @required this.maxUsers,
    @required this.colorsStatus,
    @required this.title,
    @required this.timeCreated,
    @required this.lastMessageSent,
    @required this.creatorID,
    @required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'colorsStatus': colorsStatus,
      'creatorID': creatorID,
      'maxUsers': maxUsers,
      'title': title,
      'timeCreated': timeCreated,
      'lastMessageSent': lastMessageSent,
      'tags': this.tags
    };
  }
}

Future<bool> joinSalfh({String userID, String salfhID, colorName}) async {
  final ref = firestore
      .collection('Swalf')
      .document(salfhID)
      .collection('userColors')
      .document('userColors');
  bool added = false;
  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(ref);

    if (snapshot.exists) {
      if (snapshot.data[colorName] == null) {
        transaction.update(ref, {colorName: userID});
      } else {
        transaction.update(ref, {});
      }
    }
  }).then((value) {
    added = true;
  });
  // if (added) {
  //   await addSalfhToUser(userID, salfhID, colorName);
  // }
  return added;
}

Future<Map<String, dynamic>> saveSalfh(
    {String creatorID,
    int maxUsers,
    String category,
    String title,
    List<String> tags}) async {
  Map<String, dynamic> salfh = Salfh(
          maxUsers: maxUsers,
          creatorID: creatorID,
          colorsStatus: getInitialColorStatus(creatorID, maxUsers),
          title: title,
          timeCreated: FieldValue.serverTimestamp(),
          lastMessageSent: {},
          tags: tags)
      .toMap();

  DocumentReference ref = await firestore.collection("Swalf").add(salfh);
  salfh['id'] = ref.documentID;

  String color = await getColorOfUser(userID: creatorID, salfh: salfh);
  if (ref != null) {
    print('yooo');

    // addSalfhToUser(creatorID, ref.documentID, color);
    // createSalfhChatRoom(ref.documentID);
    await for (DocumentSnapshot snapshot in firestore
        .collection('chatRooms')
        .document(salfh['id'])
        .snapshots()) {
      if (snapshot.exists) break;
    }
    return salfh;
  }
  return null;
}

void createSalfhChatRoom(String salfhID) async {
  await firestore.collection("chatRooms").document(salfhID).setData({
    kColorNames[0]: DateTime.now(),
    kColorNames[1]: DateTime.now(),
    kColorNames[2]: DateTime.now(),
    kColorNames[3]: DateTime.now(),
    kColorNames[4]: DateTime.now(),
  });
}

Map<String, dynamic> getInitialColorStatus(String creatorID, int maxUsers) {
  Map<String, dynamic> res = Map<String, dynamic>();
  String colorName = kColorNames[Random().nextInt(maxUsers)];

  for (String color in kColorNames.sublist(0, maxUsers)..shuffle()) {
    if (color == colorName) {
      res[color] = creatorID;
    } else {
      res[color] = null;
    }
  }
  return res;
}

Future<String> getColorOfUser({String userID, Map salfh}) async {
  String colorName;
  salfh['colorsStatus'].forEach((name, id) {
    id == userID ? colorName = name : null;
  });
  return colorName;
}


