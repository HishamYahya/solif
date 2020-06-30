import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/ChatInputBox.dart';
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

final maxNumOfUsers = 4;
final disabledColor = Colors.grey[400];

class _AddScreenState extends State<AddScreen> {
  String salfhName;
  String currentTag;
  int groupSize = 1;
  bool loading = false;
  TextEditingController editor = TextEditingController();
  List<String> salfhTags = ['abc'];
  List<String> suggestions = [];

  final _formKey = GlobalKey<FormState>();

  void createSalfh() async {
    // show spinner
    setState(() {
      loading = true;
    });

    //create new salfh
    String newSalfhId = await saveSalfh(
      creatorID: Provider.of<AppData>(context, listen: false).currentUserID,
      maxUsers: groupSize + 1,
      title: salfhName,
      tags: salfhTags,
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
            colorsStatus: salfh['colorsStatus'],
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

  Future<List<DocumentSnapshot>> getSuggestion(String searchkey) {
    if (searchkey == null || searchkey.length < 1) {
      return null;
    }
    print(searchkey);

    Firestore.instance
        .collection('tags')
        .where('searchKeys', arrayContains: searchkey)
        .orderBy('tagCounter', descending: true)
        .limit(10)

        // .orderBy('tagName', descending: true)
        // .where('tagName', isGreaterThanOrEqualTo: searchkey)
        // .where('tagName', isLessThan: searchkey + 'z')

        // .startAt([searchkey])
        // .endAt([searchkey + '\uf8ff'])
        .getDocuments()
        .then((snapshot) {
      print("XD");

      List<String> newSuggestions = [];

      for (var doc in snapshot.documents) {
        newSuggestions.add(doc.data.values.elementAt(1));
      }
      setState(() {
        suggestions = newSuggestions;
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: kMainColor,
      width: double.infinity,
      height: widget.isAdding ? MediaQuery.of(context).size.height * 0.7 : 0,
      curve: Curves.decelerate,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            height:
                widget.isAdding ? MediaQuery.of(context).size.height * 0.7 : 0,
            color: kMainColor,
            child: Form(
              key: _formKey,
              child: loading
                  ? Container(width: double.infinity, child: getLoadingWidget())
                  : !widget.isAdding
                      ? Container()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 16.0, right: 16.0),
                              child: Text(
                                "سالفتك؟",
                                style: kHeadingTextStyle,
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      salfhName = value;
                                    },
                                    validator: (value) {
                                      if (value == "") return "enter title";
                                      return null;
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
                            ),
                            // Container(
                            //   child: Directionality(
                            //     textDirection: TextDirection.rtl,
                            //     child: TextField(
                            //       controller: editor,
                            //       onChanged: (value) {
                            //         currentTag = value;

                            //         getSuggestion(value);
                            //       },
                            //       maxLength: 50,
                            //       style: kHintTextStyle.copyWith(
                            //           color: Colors.white),
                            //       decoration: InputDecoration(
                            //           enabledBorder: kTextFieldBorder,
                            //           focusedBorder: kTextFieldBorder,
                            //           errorBorder: kTextFieldBorder,
                            //           fillColor: Colors.white,
                            //           hintText: 'Tag',
                            //           hintStyle: kHintTextStyle,
                            //           contentPadding: EdgeInsets.only(
                            //               bottom: 40, left: 10, right: 10),
                            //           counterStyle: TextStyle(
                            //               fontSize: 15, color: Colors.white)),
                            //     ),
                            //   ),
                            // ),
                            // FlatButton(
                            //   onPressed: () {
                            //     salfhTags.add(currentTag);
                            //     // print(salfhTags.toString());
                            //     editor.clear();
                            //   },
                            //   color: Colors.white,
                            //   shape: StadiumBorder(
                            //     side: BorderSide(color: Colors.white),
                            //   ),
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(8.0),
                            //     child: Text(
                            //       "Add Tag",
                            //       style:
                            //           TextStyle(color: kMainColor, fontSize: 20),
                            //     ),
                            //   ),
                            // ),

                            Center(
                              child: Tags(
                                textField: TagsTextField(
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  hintText: 'مين تبي نعلم؟',
                                  hintTextColor: Colors.white54,
                                  suggestionTextColor: Colors.white54,
                                  constraintSuggestion: false,
                                  suggestions: suggestions,
                                  onChanged: (searchkey) {
                                    print(salfhTags);
                                    getSuggestion(searchkey);
                                  },
                                  inputDecoration: InputDecoration(
                                    enabledBorder: kTextFieldBorder,
                                    focusedBorder: kTextFieldBorder,
                                    errorBorder: kTextFieldBorder,
                                    fillColor: Colors.white,
                                    hintStyle: kHintTextStyle,
                                    contentPadding: EdgeInsets.only(
                                        bottom: 10, left: 10, right: 10),
                                    counterStyle: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  onSubmitted: (String str) {
                                    // Add item to the data source.
                                    setState(() {
                                      // required
                                      salfhTags.add(str);
                                    });
                                  },
                                ),
                                horizontalScroll: true,
                                textDirection: TextDirection.rtl,
                                itemCount: salfhTags.length,
                                itemBuilder: (index) {
                                  final item = salfhTags[index];
                                  return ItemTags(
                                    // Each ItemTags must contain a Key. Keys allow Flutter to
                                    // uniquely identify widgets.
                                    key: Key(index.toString()),
                                    index: index, // required
                                    title: item,
                                    activeColor: kMainColor,
                                    color: kMainColor,

                                    textStyle: TextStyle(
                                      fontSize: 18,
                                    ),
                                    textActiveColor: Colors.white,
                                    textColor: Colors.white,
                                    splashColor: Colors.transparent,

                                    // OR null,
                                    removeButton: ItemTagsRemoveButton(
                                      backgroundColor: Colors.blue,
                                      onRemoved: () {
                                        // Remove the item from the data source.
                                        setState(() {
                                          // required
                                          salfhTags.removeAt(index);
                                        });
                                        //required
                                        return true;
                                      },
                                    ), // OR null,
                                    onPressed: (item) => print(item),
                                    onLongPressed: (item) => print(item),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'مع كم واحد؟',
                                style: kHeadingTextStyle,
                                textAlign: TextAlign.end,
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: FlatButton(
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    createSalfh();
                                    salfhTags = [];
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
                                    style: TextStyle(
                                        color: kMainColor, fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
