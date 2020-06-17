import 'package:flutter/material.dart';

const kMainColor = Colors.grey;

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
  kColorNames[0]: Color(0xff4A154B),
  kColorNames[1]: Color(0xff2EBD7D),
  kColorNames[2]: Color(0xffECB22E),
  kColorNames[3]: Color(0xffE01E5A),
  kColorNames[4]: Color(0xff36C5F0)
};
