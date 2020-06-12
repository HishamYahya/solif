import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/SalfhTile.dart';
import 'package:solif/models/User.dart';

import '../constants.dart';

class Salfh {
  final Map<String, String> colorsStatus;
  int maxUsers;
  String category;
  String title;

  Salfh({
    @required this.maxUsers,
    @required this.category,
    this.colorsStatus,
    this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'colorsStatus': colorsStatus,
      'maxUsers': maxUsers,
      'category': category,
      'title': title
    };
  }
}

Future<String> saveSalfh(
    {String creatorID, int maxUsers, String category, String title}) async {
  final firestore = Firestore.instance;
  DocumentReference salfhID = await firestore.collection("Swalf").add(Salfh(
          maxUsers: maxUsers,
          category: category,
          colorsStatus: getInitialColorStatus(creatorID),
          title: title)
      .toMap());

  String color =
      await getColorOfUser(userID: creatorID, salfhID: salfhID.documentID);
  if (salfhID != null) {
    print('yooo');
    addSalfhToUser(creatorID, salfhID.documentID, color);
  }
  return salfhID.documentID;
}

Map<String, String> getInitialColorStatus(String creatorID) {
  Map<String, String> res = Map<String, String>();
  String colorName = kColorNames[Random().nextInt(5)];

  for (String color in kColorNames) {
    if (color == colorName) {
      res[color] = creatorID;
    } else {
      res[color] = null;
    }
  }
  return res;
}

Future<String> getColorOfUser({String userID, String salfhID}) async {
  final salfh = await getSalfh(salfhID);
  print(salfh);
  String colorName;
  salfh['colorsStatus'].forEach((name, id) {
    id == userID ? colorName = name : null;
  });
  return colorName;
}
