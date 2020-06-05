import 'package:flutter/material.dart';
import 'package:solif/screens/ChatScreen.dart';

class SalfhTile extends StatelessWidget {
  final String title;
  final Color color;
  final String category;
  // add type (1 on 1, group)
  // change to stateful and add remaining slots

  SalfhTile({this.title, this.color, this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
        Navigator.push(context,MaterialPageRoute(builder: (context) => ChatScreen(title: this.title,color: this.color,)));
      },
      child: Container(
        height: 70,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 7.5, right: 8, left: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color,
        ),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                         Align(
              alignment: Alignment.bottomRight,
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 17.5,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}