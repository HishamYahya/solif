import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/components/DialogMySwalfTab.dart';
import 'package:solif/components/DialogNewSalfhTab.dart';
import 'package:solif/models/DialogMySwalfTabModel.dart';

import '../constants.dart';

class InviteDialog extends StatefulWidget {
  final String color;
  final String userID;

  const InviteDialog({
    Key key,
    @required this.color,
    @required this.userID,
  }) : super(key: key);

  @override
  _InviteDialogState createState() => _InviteDialogState();
}

class _InviteDialogState extends State<InviteDialog> {
  bool creatingNewSalfh = true;

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
                "سولف مع",
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
        contentPadding: EdgeInsets.all(0),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          creatingNewSalfh = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          border: Border.all(color: Colors.white),
                          color: creatingNewSalfh
                              ? Colors.white
                              : Colors.transparent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            "سالفة جديدة",
                            style: TextStyle(
                              color:
                                  creatingNewSalfh ? kMainColor : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          creatingNewSalfh = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          border: Border.all(color: Colors.white),
                          color: creatingNewSalfh
                              ? Colors.transparent
                              : Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            "سالفة قديمة",
                            style: TextStyle(
                                color: creatingNewSalfh
                                    ? Colors.white
                                    : kMainColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // duration: Duration(milliseconds: 300),
                child: creatingNewSalfh
                    ? DialogNewSalfhTab(
                        userID: widget.userID,
                      )
                    : ChangeNotifierProvider<DialogMySwalfTabModel>(
                        create: (context) => DialogMySwalfTabModel(),
                        child: DialogMySwalfTab(
                          userID: widget.userID,
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
