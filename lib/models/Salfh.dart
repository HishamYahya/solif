import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/User.dart';

import '../constants.dart';

final firestore = Firestore.instance;

class Salfh {
  final Map<String, Map<String, dynamic>>
      colorsStatus; // Color: {"userID": id, "lastMessageRead":messageID, "isInChatRoom":bool}
  int maxUsers;
  String category;
  String creatorID;
  String title;
  DateTime timeCreated;
  DateTime lastMessageSentTime;
  String lastMessageSentID;

  Salfh(
      {@required this.maxUsers,
      @required this.category,
      this.colorsStatus,
      this.title,
      this.timeCreated,
      this.lastMessageSentTime,
      this.creatorID,
      this.lastMessageSentID});

  Map<String, dynamic> toMap() {
    return {
      'colorsStatus': colorsStatus,
      'creatorID': creatorID,
      'maxUsers': maxUsers,
      'category': category,
      'title': title,
      'timeCreated': timeCreated,
      'lastMessageSentTime': lastMessageSentTime,
      'lastMessageSentID': lastMessageSentID,
    };
  }
}

Future<bool> joinSalfh({String userID, String salfhID, colorName}) async {
  final ref = firestore.collection('Swalf').document(salfhID);
  bool added = false;
  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(ref);
    if (snapshot.exists) {
      if (snapshot.data['colorsStatus'][colorName]['userID'] == null) {
        final newColorsStatus = snapshot.data['colorsStatus'];
        newColorsStatus[colorName]['userID'] = userID;
        transaction.update(ref, {'colorsStatus': newColorsStatus});
      }
    }
  }).then((value) {
    added = true;
  });
  if (added) {
    await addSalfhToUser(userID, salfhID, colorName);
  }
  return added;
}

Future<String> saveSalfh(
    {String creatorID, int maxUsers, String category, String title}) async {
  DocumentReference salfhID = await firestore.collection("Swalf").add(Salfh(
        maxUsers: maxUsers,
        creatorID: creatorID,
        category: category,
        colorsStatus: getInitialColorStatus(creatorID, maxUsers),
        title: title,
        timeCreated: DateTime.now(),
        lastMessageSentTime: DateTime.now(),
        lastMessageSentID: null,
      ).toMap());

  String color =
      await getColorOfUser(userID: creatorID, salfhID: salfhID.documentID);
  if (salfhID != null) {
    print('yooo');
    addSalfhToUser(creatorID, salfhID.documentID, color);
  }
  return salfhID.documentID;
}

Map<String, Map<String, dynamic>> getInitialColorStatus(
    String creatorID, int maxUsers) {
  Map<String, Map<String, dynamic>> res = Map<String, Map<String, dynamic>>();
  String colorName = kColorNames[Random().nextInt(maxUsers)];

  for (String color in kColorNames.sublist(0, maxUsers)..shuffle()) {
    if (color == colorName) {
      res[color] = {
        'userID': creatorID,
        'lastMessageReadID': null,
        'isInChatRoom': false
      };
    } else {
      res[color] = {
        'userID': null,
        'lastMessageReadID': null,
        'isInChatRoom': false
      };
    }
  }
  return res;
}

Future<String> getColorOfUser({String userID, String salfhID}) async {
  final salfh = await getSalfh(salfhID);
  print(salfh);
  String colorName;
  salfh['colorsStatus'].forEach((name, statusMap) {
    statusMap['userID'] == userID ? colorName = name : null;
  });
  return colorName;
}
