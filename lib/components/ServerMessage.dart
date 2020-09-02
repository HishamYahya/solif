import 'package:flutter/material.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';

class ServerMessage extends StatelessWidget {
  List<Widget> _children;
  ServerMessage({String type, String color}) {
    switch (type) {
      case 'invite':
        _children = [
          Text(
            'راعي السالفة ضاف ',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
          ColoredDot(
            kOurColors[color],
          ),
        ];
        break;
      case 'join':
        _children = [
          ColoredDot(
            kOurColors[color],
          ),
          Text(
            ' خش السالفة',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ];
        break;
      case 'kick':
        _children = [
          Text(
            'راعي السالفة طرد ',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
          ColoredDot(
            kOurColors[color],
          ),
        ];
        break;
      case 'leave':
        _children = [
          ColoredDot(
            kOurColors[color],
          ),
          Text(
            ' طلع من السالفة',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _children,
          ),
        ),
      ),
    );
  }
}
