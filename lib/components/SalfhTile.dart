import 'package:flutter/material.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/ChatScreen.dart';

class SalfhTile extends StatelessWidget {
  final String title;
  final String color;
  final String category;
  final String id;
  // add type (1 on 1, group)
  // change to stateful and add remaining slots

  SalfhTile({this.title, this.color, this.category,this.id});

  @override
  Widget build(BuildContext context) {

    final Color tileColor = kOurColors[color];

    return GestureDetector(
      onTap: () {
        
        Navigator.push(context,MaterialPageRoute(builder: (context) => ChatScreen(title: this.title,color: this.color,salfhID: id,)));


    
      },
      child: Container(
        height: 70,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 7.5, right: 8, left: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: tileColor,
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