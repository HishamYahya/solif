import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  String adminID;
  String title;
  FieldValue timeCreated;
  Map lastMessageSent;
  List<String> tags;
  List<String> colorsInOrder;

  Salfh({
    @required this.maxUsers,
    @required this.colorsStatus,
    @required this.title,
    @required this.timeCreated,
    @required this.lastMessageSent,
    @required this.adminID,
    @required this.tags,
    @required this.colorsInOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'colorsStatus': colorsStatus,
      'adminID': adminID,
      'maxUsers': maxUsers,
      'title': title,
      'timeCreated': timeCreated,
      'lastMessageSent': lastMessageSent,
      'tags': this.tags,
      'colorsInOrder': colorsInOrder
    };
  }
}

Future<bool> joinSalfh(
    {String userID, String salfhID, String colorName}) async {
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'joinSalfh',
  );
  HttpsCallableResult resp = await callable
      .call(<String, dynamic>{'salfhID': salfhID, 'color': colorName});
  print('response');
  print(resp.data);
  return resp.data;
  // await firestore.runTransaction((transaction) async {
  //   final snapshot = await transaction.get(ref);

  //   if (snapshot.exists) {
  //     if (snapshot.data[colorName] == null) {
  //       transaction.update(ref, {colorName: userID});
  //     } else {
  //       transaction.update(ref, {});
  //     }
  //   }
  // }).then((value) {
  //   added = true;
  // });
  // if (added) {
  //   await addSalfhToUser(userID, salfhID, colorName);
  // }
}

Future<Map<String, dynamic>> saveSalfh(
    {String adminID, String category, String title, List<String> tags}) async {
  // List colorStatusResult = getInitialColorStatus(adminID, maxUsers);
  // Map<String, dynamic> colorStatus = getInitialColorStatus(adminID, maxUsers);
  // //String creatorColor = colorStatusResult[1];

  // Map<String, dynamic> salfh = Salfh(
  //     maxUsers: maxUsers,
  //     adminID: adminID,
  //     colorsStatus: colorStatus,
  //     title: title,
  //     timeCreated: FieldValue.serverTimestamp(),
  //     lastMessageSent: {},
  //     tags: tags,
  //     colorsInOrder: []).toMap();

  // DocumentReference ref = await firestore.collection("Swalf").add(salfh);
  // salfh['id'] = ref.documentID;

  // String color = await getColorOfUser(userID: adminID, salfh: salfh);
  // if (ref != null) {
  //   print('yooo');

  //   // addSalfhToUser(adminID, ref.documentID, color);
  //   // createSalfhChatRoom(ref.documentID);

  //   return salfh;
  // }
  // return null;

  final HttpsCallable callable =
      CloudFunctions.instance.getHttpsCallable(functionName: 'createSalfh');
  final res =
      await callable.call(<String, dynamic>{'title': title, 'tags': tags});
  final salfhID = res.data['salfhID'];
  if (salfhID == null) return null;

  dynamic salfh = await firestore.collection('Swalf').document(salfhID).get();
  salfh = salfh.data;
  salfh['id'] = salfhID;
  return salfh;
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

Map<String, dynamic> getInitialColorStatus(String adminID, int maxUsers) {
  Map<String, dynamic> res = Map<String, dynamic>();
  List shuffledNames = [...kColorNames]..shuffle();
  String colorName = shuffledNames[Random().nextInt(maxUsers)];
  String creatorColor;

  for (String color in shuffledNames.sublist(0, maxUsers)..shuffle()) {
    if (color == colorName) {
      creatorColor = color;
      res[color] = adminID;
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

Future<void> removeUser({String userColor, String salfhID}) async {
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'removeUser',
  );
  dynamic resp = await callable
      .call(<String, dynamic>{'salfhID': salfhID, 'color': userColor});
  print(resp.data);
}
