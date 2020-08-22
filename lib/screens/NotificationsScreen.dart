import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/models/AppData.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationTiles = Provider.of<AppData>(context).notificationTiles;
    return ListView(
      children: notificationTiles != null
          ? [...notificationTiles, ...notificationTiles]
          : [LoadingWidget('')],
    );
  }
}
