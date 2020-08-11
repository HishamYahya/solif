import 'package:flutter/material.dart';
import 'package:solif/components/ColoredDot.dart';

import '../constants.dart';

class InviteDialog extends StatefulWidget {
  const InviteDialog({
    Key key,
    @required this.color,
  }) : super(key: key);

  final String color;

  @override
  _InviteDialogState createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        elevation: 0,
        backgroundColor: kMainColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.transparent,
            width: 0,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        titlePadding: EdgeInsets.all(0),
        title: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "افتح سالفة مع",
                style: kHeadingTextStyle.copyWith(
                    fontSize: 26,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ColoredDot(
                  kOurColors[widget.color],
                ),
              ),
            ],
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  child: TextField(
                    maxLength: 30,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                        enabledBorder: kTextFieldBorder,
                        disabledBorder: kTextFieldBorder,
                        focusedBorder: kTextFieldBorder,
                        hintText: "موضوع سالفتكم",
                        hintStyle: kHintTextStyle.copyWith(fontSize: 24),
                        counterStyle: TextStyle(color: Colors.white54)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                  child: FlatButton(
                    onPressed: null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "افتح السالفة",
                        style: TextStyle(color: kMainColor, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
