import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
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
    switch (widget.type) {
      case 'invite':
        return [
          Icon(
            Icons.chat_bubble_outline,
            color: Provider.of<Preferences>(context, listen: false)
                .currentColors['red'],
          ),
          Column(
            children: [
              Text(
                ':احد ضافك لسالفة بعنوان ',
                style: TextStyle(
                    color: darkMode ? kDarkModeTextColor60 : Colors.grey[800]),
              ),
              Text(
                widget.payload['title'],
                style: TextStyle(
                  fontSize: 20,
                  color: darkMode ? kDarkModeTextColor87 : Colors.grey[850],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ];
      default:
        return [];
    }
  }

  @override
  void initState() {
    bool darkMode = Provider.of<Preferences>(context, listen: false).darkMode;

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
            );
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buildWidgets(),
            ),
          ),
        ),
      ),
    );
  }
}
