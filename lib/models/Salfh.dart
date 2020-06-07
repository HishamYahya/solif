import 'package:flutter/material.dart';
import 'package:solif/models/Message.dart';

class Salfh {
  Map<String,String> userIDs;
  String id;
  int maxUsers;
  String type;

  Salfh({
    @required this.id,
    @required this.maxUsers,
    @required this.type,
    @required this.userIDs,
  });

  Map<String, dynamic> toMap() {
    return {'userIDs': userIDs, 'id': id, 'maxUsers': maxUsers, 'type': type};
  }
}
