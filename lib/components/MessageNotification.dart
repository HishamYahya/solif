import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Preferences.dart';

class MessageNotification extends StatelessWidget {
  final String title;
  final String subtitle;
  final String color;

  MessageNotification({
    @required this.title,
    @required this.subtitle,
    this.color,
  });

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
                  title,
                  style: TextStyle(
                    color: darkMode ? kDarkModeTextColor87 : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(
                    color: darkMode ? kDarkModeTextColor87 : Colors.grey[850],
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: color != null
                    ? ColoredDot(
                        colors[color],
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
