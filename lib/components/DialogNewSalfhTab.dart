import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';
import 'package:solif/models/Salfh.dart';

import '../constants.dart';

class DialogNewSalfhTab extends StatefulWidget {
  final String userID;

  const DialogNewSalfhTab({
    this.userID,
    Key key,
  }) : super(key: key);

  @override
  _DialogNewSalfhTabState createState() => _DialogNewSalfhTabState();
}

class _DialogNewSalfhTabState extends State<DialogNewSalfhTab> {
  String salfhTitle;
  String loadingMessage;
  final _formKey = GlobalKey<FormState>();

  void createSalfh() async {
    bool isArabic = Provider.of<Preferences>(context, listen: false).isArabic;
    setState(() {
      loadingMessage = isArabic ? 'نفتح سالفتكم...' : 'Creating chat...';
    });
    final newSalfh = await saveSalfh(
      adminID: Provider.of<AppData>(context, listen: false).currentUserID,
      title: salfhTitle,
      tags: [],
    );
    if (newSalfh != null) {
      if (mounted)
        setState(() {
          loadingMessage = isArabic ? 'نضيفكم لها...' : 'Adding you to it...';
        });
      final Map<String, dynamic> colorsStatus = newSalfh['colorsStatus'];
      String colorName;
      for (String color in colorsStatus.keys) {
        if (colorsStatus[color] == null) {
          colorName = color;
          break;
        }
      }
      await addUserToSalfh(
        colorName: colorName,
        context: context,
        salfhID: newSalfh['id'],
        userID: widget.userID,
      );

      if (mounted) {
        setState(() {
          loadingMessage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Provider.of<Preferences>(context).isArabic;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: loadingMessage == null
          ? Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Directionality(
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                      child: Container(
                        width: double.infinity,
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            salfhTitle = value;
                          },
                          maxLength: 30,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                              enabledBorder: kTextFieldBorder,
                              disabledBorder: kTextFieldBorder,
                              focusedBorder: kTextFieldBorder,
                              hintText: isArabic
                                  ? "موضوع سالفتكم"
                                  : "Give your chat a title",
                              hintStyle: kHintTextStyle.copyWith(fontSize: 20),
                              counterStyle: TextStyle(color: Colors.white54)),
                        ),
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
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            createSalfh();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            isArabic ? "افتح السالفة" : 'Open Chat',
                            style: TextStyle(color: kMainColor, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : LoadingWidget(
              loadingMessage,
              color: Colors.white,
            ),
    );
  }
}
