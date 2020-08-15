import 'package:flutter/material.dart';

import '../constants.dart';

class LoadingWidget extends StatelessWidget {
  final String text;
  final Color color;

  LoadingWidget(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 5,
            backgroundColor: color ?? kMainColor,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            text,
            style: kHeadingTextStyle.copyWith(color: color ?? kMainColor),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
