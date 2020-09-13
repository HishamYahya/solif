import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/TagChip.dart';
import 'package:solif/models/Preferences.dart';

import '../constants.dart';

final Firestore firestore = Firestore.instance;

class TagSearchSelectDialog extends StatefulWidget {
  final List<String> tags;
  final Function(String) onAdd;
  final Function(String) onRemove;

  TagSearchSelectDialog({this.onAdd, this.onRemove, this.tags});

  @override
  _TagSearchSelectDialogState createState() => _TagSearchSelectDialogState();
}

class _TagSearchSelectDialogState extends State<TagSearchSelectDialog> {
  Future<QuerySnapshot> _tagListFuture;
  List<String> tags;
  String searchTerm = '';
  FocusNode _textfieldFocusNode;
  Timer timer = Timer(Duration(milliseconds: 0), () => {});

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textfieldFocusNode = FocusNode();
    tags = widget.tags;
    _tagListFuture = firestore
        .collection('tags')
        .orderBy('tagCounter', descending: true)
        .limit(10)
        .getDocuments();
  }

  List<TagChip> getTagChips() {
    List<TagChip> chips = [];
    for (var tagName in tags.reversed) {
      chips.add(
        TagChip(
          tagName: tagName,
          onRemove: () {
            removeTag(tagName);
          },
        ),
      );
    }
    return chips;
  }

  void search() {
    setState(() {
      if (searchTerm.isNotEmpty)
        _tagListFuture = firestore
            .collection('tags')
            .where('searchKeys', arrayContains: searchTerm)
            .orderBy('tagCounter', descending: true)
            .limit(10)
            .getDocuments();
      else {
        _tagListFuture = firestore
            .collection('tags')
            .orderBy('tagCounter', descending: true)
            .limit(10)
            .getDocuments();
      }
    });
  }

  void removeTag(String tagName) {
    setState(() {
      widget.onRemove(tagName);
    });
  }

  void addTag(String tagName) {
    if (tags.length < 5) {
      setState(() {
        widget.onAdd(tagName);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textfieldFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AlertDialog(
        clipBehavior: Clip.antiAlias,
        backgroundColor: darkMode ? kDarkModeDarkGrey : Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        contentPadding: EdgeInsets.all(0),
        content: Stack(
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                minHeight: 0,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: darkMode ? kDarkModeLightGrey : Colors.grey[300],
                      ),
                      child: TextField(
                        focusNode: _textfieldFocusNode,
                        maxLength: 30,
                        cursorRadius: Radius.circular(500),
                        cursorColor: Colors.black,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) {
                          searchTerm = value;
                          timer.cancel();
                          timer = Timer(Duration(milliseconds: 300), () {
                            search();
                          });
                        },
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_textfieldFocusNode);
                          addTag(value);
                        },
                        style: TextStyle(
                          color: darkMode
                              ? kDarkModeTextColor87
                              : Colors.grey[800],
                          textBaseline: TextBaseline.alphabetic,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0.3),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: darkMode
                                ? kDarkModeTextColor60
                                : Colors.grey[800],
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelText: isArabic
                              ? "ابحث عن موضوع تبي تسولف عنه"
                              : 'Search topics',
                          counterText: "",
                          labelStyle: TextStyle(
                            color: darkMode
                                ? kDarkModeTextColor38
                                : Colors.grey[800],
                            textBaseline: TextBaseline.alphabetic,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  widget.tags.isNotEmpty
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                child: Theme(
                                  data: ThemeData(
                                    highlightColor: darkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                                  ),
                                  child: Scrollbar(
                                    isAlwaysShown: true,
                                    controller: _scrollController,
                                    child: ListView(
                                      controller: _scrollController,
                                      padding: EdgeInsets.only(bottom: 8),
                                      scrollDirection: Axis.horizontal,
                                      children: getTagChips(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${widget.tags.length}/5',
                                style: TextStyle(
                                  color: widget.tags.length == 5
                                      ? kCancelRedColor
                                      : darkMode
                                          ? kDarkModeTextColor87
                                          : Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  Expanded(
                    child: FutureBuilder(
                      future: _tagListFuture,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return LoadingWidget('');
                          case ConnectionState.done:
                            if (snapshot.hasData &&
                                snapshot.data.documents.length != 0) {
                              final List<DocumentSnapshot> docs =
                                  snapshot.data.documents;
                              return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index].data;
                                  return Container(
                                    decoration: darkMode
                                        ? BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: kDarkModeTextColor38,
                                                width: 0.7,
                                              ),
                                            ),
                                          )
                                        : null,
                                    child: ListTile(
                                      title: Text(
                                        doc['tagName'],
                                        style: TextStyle(
                                          color: darkMode
                                              ? kDarkModeTextColor87
                                              : Colors.grey[850],
                                        ),
                                      ),
                                      subtitle: Text(
                                        doc['tagCounter'].toString() +
                                            (isArabic ? ' سالفة' : ' chats'),
                                        style: TextStyle(
                                          color: darkMode
                                              ? kDarkModeTextColor60
                                              : Colors.grey[800],
                                        ),
                                      ),
                                      trailing:
                                          widget.tags.contains(doc['tagName'])
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: kMainColor,
                                                )
                                              : null,
                                      onTap: () {
                                        widget.tags.contains(doc['tagName'])
                                            ? removeTag(doc['tagName'])
                                            : addTag(doc['tagName']);
                                      },
                                      shape: BeveledRectangleBorder(
                                        side: BorderSide(
                                            color: Colors.white, width: 2),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container(
                                decoration: darkMode
                                    ? BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: kDarkModeTextColor38,
                                            width: 0.7,
                                          ),
                                        ),
                                      )
                                    : null,
                                child: ListTile(
                                  title: Text(
                                    searchTerm,
                                    style: TextStyle(
                                      color: darkMode
                                          ? kDarkModeTextColor87
                                          : Colors.grey[850],
                                    ),
                                  ),
                                  subtitle: Text(
                                    isArabic
                                        ? 'ولا سالفة, خلك اول واحد!'
                                        : '0 chats, Be the first one!',
                                    style: TextStyle(
                                      color: darkMode
                                          ? kDarkModeTextColor60
                                          : Colors.grey[800],
                                    ),
                                  ),
                                  trailing: widget.tags.contains(searchTerm)
                                      ? Icon(
                                          Icons.check_circle,
                                          color: kMainColor,
                                        )
                                      : null,
                                  onTap: () {
                                    widget.tags.contains(searchTerm)
                                        ? removeTag(searchTerm)
                                        : addTag(searchTerm);
                                  },
                                  shape: BeveledRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              );
                            }
                            break;

                          default:
                            return LoadingWidget('');
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: ClipOval(
                  child: Container(
                    color: kMainColor,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
