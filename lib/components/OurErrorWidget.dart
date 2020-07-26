import 'package:flutter/material.dart';

class OurErrorWidget extends StatelessWidget {
  final String errorMessage; 

  OurErrorWidget({this.errorMessage});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(errorMessage),
    );
  }
}