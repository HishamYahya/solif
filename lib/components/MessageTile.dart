import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final String message;
  final Color color;

  const MessageTile({Key key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: Colors.black,
        ),
      ),
    );
  }
}
