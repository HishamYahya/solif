import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/FirebaseServices.dart';
import 'package:solif/components/ChatInputBox.dart';
import 'package:solif/components/TagChip.dart';
import 'package:solif/components/TagSearchResultsList.dart';
import 'package:solif/components/TagSearchSelectDialog.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';
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
    final newSalfh = await saveSalfh(
      adminID: Provider.of<AppData>(context, listen: false).currentUserID,
      title: salfhName,
      tags: salfhTags,
    );

    //if suceeded
    if (newSalfh != null) {
      String colorName = await getColorOfUser(
        userID: Provider.of<AppData>(context, listen: false).currentUserID,
        salfh: newSalfh,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            title: newSalfh['title'],
            colorsStatus: newSalfh['colorsStatus'],
            color: colorName,
            salfhID: newSalfh['id'],
          ),
        ),
      );
    }
    setState(() {
      loading = false;
    });
    widget.onClose();
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

  List<TagChip> getTagChips() {
    List<TagChip> chips = [];
    for (var tagName in salfhTags.reversed) {
      chips.add(
        TagChip(
          tagName: tagName,
          onRemove: () {
            setState(() {
              salfhTags.remove(tagName);
            });
          },
        ),
      );
    }
    return chips;
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
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: kMainColor,
      width: double.infinity,
      height: widget.isAdding ? 400 : 0,
      curve: Curves.decelerate,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          overflow: Overflow.clip,
          children: [
            SingleChildScrollView(
              child: Container(
                height: 400,
                color: kMainColor,
                child: Form(
                  key: _formKey,
                  child: loading
                      ? Container(
                          width: double.infinity, child: getLoadingWidget())
                      : !widget.isAdding
                          ? Container()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Flexible(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 16,
                                    ),
                                    child: Container(
                                      child: Directionality(
                                        textDirection: isArabic
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        child: TextFormField(
                                          autofocus: false,
                                          onChanged: (value) {
                                            salfhName = value;
                                          },
                                          validator: (value) {
                                            if (value == "")
                                              return isArabic
                                                  ? 'ادخل عنوان'
                                                  : "Enter title";
                                            return null;
                                          },
                                          maxLength: 30,
                                          style: kHintTextStyle.copyWith(
                                              color: Colors.white),
                                          decoration: InputDecoration(
                                              enabledBorder: kTextFieldBorder,
                                              focusedBorder: kTextFieldBorder,
                                              errorBorder: kTextFieldBorder,
                                              fillColor: Colors.white,
                                              hintText: isArabic
                                                  ? 'وش تبي تسولف عنه؟'
                                                  : 'What do you want to talk about?',
                                              hintStyle: kHintTextStyle,
                                              contentPadding: EdgeInsets.only(
                                                  bottom: 60,
                                                  left: 10,
                                                  right: 10),
                                              counterStyle: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white)),
                                        ),
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
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        clipBehavior: Clip.none,
                                        spacing: 2,
                                        runSpacing: 8,
                                        children: [
                                          ...getTagChips(),
                                          GestureDetector(
                                            onTap: () => showDialog(
                                              context: context,
                                              child: TagSearchSelectDialog(
                                                tags: salfhTags,
                                                onAdd: (String tagName) {
                                                  setState(() {
                                                    salfhTags.add(tagName);
                                                  });
                                                },
                                                onRemove: (String tagName) {
                                                  setState(() {
                                                    salfhTags.remove(tagName);
                                                  });
                                                },
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: 200,
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(500),
                                                    ),
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        spreadRadius: 2,
                                                        blurRadius: 1,
                                                        offset: Offset(-2,
                                                            0), // changes position of shadow
                                                      ),
                                                    ]),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.add,
                                                        size: 18,
                                                        color: kMainColor,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        isArabic
                                                            ? 'اضافة مواضيع'
                                                            : 'Add topics',
                                                        style: TextStyle(
                                                          color: kMainColor,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
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
                                          isArabic
                                              ? "افتح السالفة"
                                              : "Open Chat",
                                          style: TextStyle(
                                              color: kMainColor, fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
