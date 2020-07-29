import 'package:flutter/material.dart';

const kHeadingTextStyle = TextStyle(
  fontSize: 40,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

const kTextFieldBorder = UnderlineInputBorder(
  borderSide: BorderSide(
    color: Colors.white,
  ),
);

final kHintTextStyle = TextStyle(
  fontSize: 30,
  color: Colors.white54,
);

const List<String> kColorNames = ["purple", "green", "yellow", "red", "blue"];
// makes changing color names in the future easier, if ever needed
// always use this when refering to colors.
// use example to get the first color:
// color: kOurColors[kColorNames[0]];

final Map<String, Color> kOurColors = {
  kColorNames[0]: Color(0xff6E2594).withAlpha(100),
  kColorNames[1]: Color(0xff82BC24),
  kColorNames[2]: Color(0xffF48701),
  kColorNames[3]:  Color(0xffCC2836),
  kColorNames[4]: Color(0xff1982c4)
};    

final kMainColor = Color(0XFF1b98e0);
  
final kMinimumSalfhTiles = 10;
