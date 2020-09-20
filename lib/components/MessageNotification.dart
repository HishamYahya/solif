import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/CurrentOpenChat.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/ChatScreen.dart';

import 'LoadingWidget.dart';
import 'OurErrorWidget.dart';

final firestore = Firestore.instance;

class MessageNotification extends StatefulWidget {
  final String title;
  final String subtitle;
  final String color;
  final String salfhID;

  MessageNotification(
      {@required this.title,
      @required this.subtitle,
      this.color,
      this.salfhID});

  @override
  _MessageNotificationState createState() => _MessageNotificationState();
}

class _MessageNotificationState extends State<MessageNotification> {
  onTap() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        content: LoadingWidget(''),
      ),
    );
    final salfh = await firestore.collection('Swalf').doc(widget.salfhID).get();
    if (salfh != null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      String color;
      salfh.data()['colorsStatus'].forEach((colorName, id) {
        if (id == Provider.of<AppData>(context, listen: false).currentUserID) {
          color = colorName;
        }
      });
      Provider.of<CurrentOpenChat>(context, listen: false)
          .openChat(widget.salfhID);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            title: salfh.data()['title'],
            color: color,
            colorsStatus: salfh.data()['colorsStatus'],
            salfhID: widget.salfhID,
            adminID: salfh.data()['adminID'],
          ),
        ),
      ).then((value) =>
          Provider.of<CurrentOpenChat>(context, listen: false).closeChat());
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        child: AlertDialog(
          content: OurErrorWidget(
            errorMessage: 'salfh returned null',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    Map<String, Color> colors = Provider.of<Preferences>(context).currentColors;
    return SafeArea(
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dy < 0) OverlaySupportEntry.of(context).dismiss();
        },
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: darkMode ? kDarkModeLightGrey : Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: ListTile(
                dense: true,
                title: Text(
                  widget.title,
                  style: TextStyle(
                    color: darkMode ? kDarkModeTextColor87 : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  widget.subtitle,
                  style: TextStyle(
                    color: darkMode ? kDarkModeTextColor87 : Colors.grey[850],
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: widget.color != null
                    ? ColoredDot(
                        colors[widget.color],
                        height: 30,
                        width: 30,
                      )
                    : null,
                trailing: GestureDetector(
                  onTap: () => OverlaySupportEntry.of(context).dismiss(),
                  child: Icon(
                    Icons.close,
                    color: darkMode ? kDarkModeTextColor60 : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
