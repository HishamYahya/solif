import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  final bool isAdding;

  AddScreen({this.isAdding});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: Colors.blue,
      width: double.infinity,
      height: widget.isAdding ? MediaQuery.of(context).size.height * 0.7 : 0,
      curve: Curves.decelerate,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("add", style: TextStyle(fontSize: 20)),
          Text("screen", style: TextStyle(fontSize: 20)),
          Text("here", style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
