import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:solif/models/User.dart';

import '../constants.dart';

class Salfh {
  final Map<String, bool> colorsStatus;
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
    return {'colorsStatus': colorsStatus, 'maxUsers': maxUsers, 'category': category,'title':title};
  }
}




void saveSalfh({String createrColor,int maxUsers,String category,String title}) async{
  final firestore = Firestore.instance; 

   DocumentReference salfhId =  await firestore
        .collection("Swalf")  
        .add(Salfh(
          maxUsers: maxUsers,
          category: category,
          colorsStatus: getInitialColorStatus(createrColor),
          title: title
          

        ) 
            .toMap());

  addSalfhToUser("00user", salfhId.documentID, createrColor);
  }










  
Map<String,bool> getInitialColorStatus(String createrColor){

  Map<String,bool> res = Map<String,bool>();

  for(String color in kColorNames){
    if(color == createrColor){
      res[color] = true;
    }
    else{
      res[color] = false;
    }
  }
  return res; 

}
//    Random r = Random();
   // String randomlyGeneratedColor = kColorNames[r.nextInt(kColorNames.length)];