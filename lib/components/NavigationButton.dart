import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  // more fields needed.
  final String title;

  NavigationButton({this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Text(
          "button $title",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        onTap: () {
          print("Test button $title");
        },
      ),
    );
  }
}