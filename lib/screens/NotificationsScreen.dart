import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';

import '../constants.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationTiles = Provider.of<AppData>(context).notificationTiles;
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    return ListView(
      children: notificationTiles != null
          ? notificationTiles.isNotEmpty
              ? notificationTiles
              : [
                  Container(
                    padding: EdgeInsets.all(8),
                    height: 200,
                    child: Center(
                      child: Text(
                        isArabic
                            ? "ما فيه تنبيهات"
                            : "There are no notification to show yet",
                        style: TextStyle(
                          color: darkMode
                              ? kDarkModeTextColor60
                              : Colors.grey[500],
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ]
          : [LoadingWidget('')],
    );
  }
}
