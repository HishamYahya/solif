import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/CurrentOpenChat.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/screens/ChatScreen.dart';

final firestore = Firestore.instance;

class NotificationTile extends StatefulWidget {
  final String type;
  final Map payload;

  NotificationTile({this.type, this.payload});

  @override
  _NotificationTileState createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  Function onTap;

  List<Widget> buildWidgets() {
    bool darkMode = Provider.of<Preferences>(context, listen: false).darkMode;
    bool isArabic = Provider.of<Preferences>(context, listen: false).isArabic;
    switch (widget.type) {
      case 'invite':
        return [
          Icon(
            Icons.chat_bubble_outline,
            color: Provider.of<Preferences>(context, listen: false)
                .currentColors['red'],
          ),
          Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? 'احد ضافك لسالفة بعنوان: '
                      : 'Someone added you to a chat: ',
                  style: TextStyle(
                      color:
                          darkMode ? kDarkModeTextColor60 : Colors.grey[800]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    widget.payload['title'],
                    style: TextStyle(
                      fontSize: 20,
                      color: darkMode ? kDarkModeTextColor87 : Colors.grey[850],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  void initState() {
    switch (widget.type) {
      case 'invite':
        onTap = () async {
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
          final salfh = await firestore
              .collection('Swalf')
              .document(widget.payload['id'])
              .get();
          print(salfh['colorsStatus'].runtimeType);
          if (salfh != null) {
            Navigator.pop(context);
            String color;
            salfh['colorsStatus'].forEach((colorName, id) {
              if (id ==
                  Provider.of<AppData>(context, listen: false).currentUserID) {
                color = colorName;
              }
            });
            Provider.of<CurrentOpenChat>(context, listen: false)
                .openChat(widget.payload['id']);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  title: salfh['title'],
                  color: color,
                  colorsStatus: salfh['colorsStatus'],
                  salfhID: widget.payload['id'],
                  adminID: salfh['adminID'],
                ),
              ),
            ).then((value) =>
                Provider.of<CurrentOpenChat>(context, listen: false)
                    .closeChat());
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
        };
        break;
      default:
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: darkMode ? kDarkModeDarkGrey : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buildWidgets(),
            ),
          ),
        ),
      ),
    );
  }
}
