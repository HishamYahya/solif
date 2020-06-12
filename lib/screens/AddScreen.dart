import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Salfh.dart';
import 'package:solif/screens/ChatScreen.dart';

class AddScreen extends StatefulWidget {
  final bool isAdding;
  final Function onClose;

  AddScreen({this.isAdding, this.onClose});

  @override
  _AddScreenState createState() => _AddScreenState();
}

final maxNumOfUsers = 5;
final disabledColor = Colors.grey[400];

class _AddScreenState extends State<AddScreen> {
  String salfhName;
  int groupSize = 1;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();

  void createSalfh() async {
    // show spinner
    setState(() {
      loading = true;
    });

    //create new salfh
    String newSalfhId = await saveSalfh(
      creatorID: Provider.of<AppData>(context, listen: false).currentUserID,
      maxUsers: groupSize,
      title: salfhName,
    );

    //if suceeded
    if (newSalfhId != null) {
      Provider.of<AppData>(context, listen: false).reloadUsersSalfhTiles();
      String colorName = await getColorOfUser(
        userID: Provider.of<AppData>(context, listen: false).currentUserID,
        salfhID: newSalfhId,
      );
      final salfh = await getSalfh(newSalfhId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            title: salfh['title'],
            color: colorName,
            salfhID: newSalfhId,
          ),
        ),
      );
      setState(() {
        loading = false;
      });
      widget.onClose();
    }
  }

  Widget getLoadingWidget() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProgressIndicator(
        backgroundColor: Colors.white,
        strokeWidth: 5,
      ),
      SizedBox(
        height: 20,
      ),
      Text(
        "...نفتح سالفتك",
        style: kHeadingTextStyle,
        textAlign: TextAlign.end,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: Colors.blue,
      width: double.infinity,
      height: widget.isAdding ? MediaQuery.of(context).size.height * 0.7 : 0,
      curve: Curves.decelerate,
      child: Form(
        key: _formKey,
        child: loading
            ? getLoadingWidget()
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: !widget.isAdding
                    ? null
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            "سالفتك؟",
                            style: kHeadingTextStyle,
                            textAlign: TextAlign.end,
                          ),
                          Container(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: TextFormField(
                                onChanged: (value) {
                                  salfhName = value;
                                },
                                maxLength: 50,
                                style: kHintTextStyle.copyWith(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                    enabledBorder: kTextFieldBorder,
                                    focusedBorder: kTextFieldBorder,
                                    errorBorder: kTextFieldBorder,
                                    fillColor: Colors.white,
                                    hintText: 'وش تبي تسولف عنه؟',
                                    hintStyle: kHintTextStyle,
                                    contentPadding: EdgeInsets.only(
                                        bottom: 40, left: 10, right: 10),
                                    counterStyle: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                              ),
                            ),
                          ),
                          Text(
                            'مع كم واحد؟',
                            style: kHeadingTextStyle,
                            textAlign: TextAlign.end,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    if (groupSize > 1) {
                                      setState(() {
                                        groupSize--;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.remove_circle_outline,
                                    size: 50,
                                    color: groupSize > 1
                                        ? Colors.white
                                        : disabledColor,
                                  ),
                                ),
                                Text(
                                  '$groupSize',
                                  style: kHeadingTextStyle,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (groupSize < maxNumOfUsers) {
                                      setState(() {
                                        groupSize++;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    size: 50,
                                    color: groupSize < maxNumOfUsers
                                        ? Colors.white
                                        : disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                createSalfh();
                              }
                            },
                            color: Colors.white,
                            shape: StadiumBorder(
                              side: BorderSide(color: Colors.white),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "افتح السالفة",
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 20),
                              ),
                            ),
                          )
                        ],
                      ),
              ),
      ),
    );
  }
}
