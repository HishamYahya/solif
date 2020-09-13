class ValidFireBaseStringConverter {
  static final RegExp arabicRegExp = RegExp(r'[ء-ي]');

// any string not of this form shouldn't be accepted
// can only be: english letters, arabic letters, numbers, and the underscore.
  static final RegExp generalValidStrings = RegExp(r'^[a-zA-Z0-9ء-ي_]+$');

  static String convertString(String str) {
    if (arabicRegExp.hasMatch(str)) {
      // if the string has any arabic characters
      for (int ind = 0; ind < str.length; ind++) {
        if (arabicRegExp.hasMatch(str[ind])) {
          String newChar = String.fromCharCode(
              str[ind].codeUnits[0] - 'ء'.codeUnits[0] + 65);
          str = str.replaceAll(str[ind], newChar);
        }
      }

      str += 'AR';
    } else {
      str += 'EN';
    }
    return str;
  }

  static List<String> convertList(List<String> strList) {
    List<String> newList = [];
    for (String str in strList) {
      newList.add(convertString(str));
    }
    return newList;
  }
}
