import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/Preferences.dart';

class ServerMessage extends StatefulWidget {
  final String type;
  final String color;
  ServerMessage({this.type, this.color});

  @override
  _ServerMessageState createState() => _ServerMessageState();
}

class _ServerMessageState extends State<ServerMessage> {
  List<Widget> _children;

  @override
  void initState() {
    String color = widget.color;
    bool darkMode = Provider.of<Preferences>(context, listen: false).darkMode;
    bool isArabic = Provider.of<Preferences>(context, listen: false).isArabic;
    Map<String, Color> currentColors =
        Provider.of<Preferences>(context, listen: false).currentColors;

    switch (widget.type) {
      case 'invite':
        _children = [
          Text(
            isArabic ? 'راعي السالفة ضاف ' : 'Admin added ',
            style: TextStyle(
                color: darkMode ? kDarkModeTextColor87 : Colors.grey[600],
                fontSize: 16),
          ),
          ColoredDot(
            currentColors[color],
          ),
        ];
        break;
      case 'join':
        _children = [
          ColoredDot(
            currentColors[color],
          ),
          Text(
            isArabic ? ' خش السالفة' : ' joined',
            style: TextStyle(
                color: darkMode ? kDarkModeTextColor87 : Colors.grey[600],
                fontSize: 16),
          ),
        ];
        break;
      case 'kick':
        _children = [
          Text(
            isArabic ? 'راعي السالفة طرد ' : 'Admin kicked ',
            style: TextStyle(
                color: darkMode ? kDarkModeTextColor87 : Colors.grey[600],
                fontSize: 16),
          ),
          ColoredDot(
            currentColors[color],
          ),
        ];
        break;
      case 'leave':
        _children = [
          ColoredDot(
            currentColors[color],
          ),
          Text(
            isArabic ? ' طلع من السالفة' : 'left',
            style: TextStyle(
                color: darkMode ? kDarkModeTextColor87 : Colors.grey[600],
                fontSize: 16),
          ),
        ];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Provider.of<Preferences>(context).isArabic;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _children,
          ),
        ),
      ),
    );
  }
}
