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
  fontSize: 18,
  color: Colors.white54,
);

const List<String> kColorNames = ["purple", "green", "yellow", "red", "blue"];
// makes changing color names in the future easier, if ever needed
// always use this when refering to colors.
// use example to get the first color:
// color: kOurColors[kColorNames[0]];
final Map<String, Color> kOurColorsDark = {
  kColorNames[0]: Color(0xff540d6e),
  kColorNames[1]: Color(0xff179248),
  kColorNames[2]: Color(0xffc99c34),
  kColorNames[3]: Color(0xffa2103d),
  kColorNames[4]: Color(0xff2d94b4)
};
final Map<String, Color> kOurColorsLight = {
  kColorNames[0]: Color(0xff540d6e),
  kColorNames[1]: Color(0xff2EBD7D),
  kColorNames[2]: Color(0xffECB22E),
  kColorNames[3]: Color(0xffE01E5A),
  kColorNames[4]: Color(0xff36C5F0)
};

final kMainColor = Color(0XFF1b98e0);

final kMinimumSalfhTiles = 10;

final kDarkTextColor = Colors.grey[800];

final kCancelRedColor = Colors.red[300];

final kDarkModeTextColor87 = Colors.white.withOpacity(0.87);
final kDarkModeTextColor60 = Colors.white.withOpacity(0.60);
final kDarkModeTextColor38 = Colors.white.withOpacity(0.38);

// final kDarkModeDarkGrey = Color(0XFF121212);
final kDarkModeDarkGrey = Color(0XFF121212);
final kDarkModeLightGrey = Color(0XFF292929);
