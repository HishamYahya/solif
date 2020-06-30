import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/CustomSliverAppBar.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/TagTile.dart';
import 'package:solif/models/AppData.dart';

import '../constants.dart';

class UserInterestScreen extends StatefulWidget {
  @override
  _UserInterestScreenState createState() => _UserInterestScreenState();
}

class _UserInterestScreenState extends State<UserInterestScreen> {
  final _fcm = FirebaseMessaging();
  Future<List<TagTile>> _userTags;

  initState() {
    if (!isTagsLoadedLocally()) {
      print("not loaded");
      _userTags = getInterests();
    } else {
      _userTags = null;
    }

    super.initState();
  }

  bool isTagsLoadedLocally() {
    return Provider.of<AppData>(context, listen: false).isTagsLoadedLocally();
  }

  void cancelTag(String tag) {
    Provider.of<AppData>(context, listen: false).deleteTag(tag);
  }

  void addTag(String tag) {
    Provider.of<AppData>(context, listen: false).addTag(tag);
  }

  Future<List<TagTile>> getInterests() async {
    final firestore = Firestore.instance;
    String userID = Provider.of<AppData>(context, listen: false).currentUserID;
    List<TagTile> tags = [];
    print("?XD");
    await firestore
        .collection("users")
        .document(userID)
        .collection('userTags')
        .orderBy('timeAdded')
        .getDocuments()
        .then((value) {
      for (var doc in value.documents.reversed) {
        
        print("13242423");
        print(doc['tagName']);
        tags.add(TagTile(
          tagName: doc['tagName'],
        ));
      }
    });
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    print(_userTags);
    //print(Provider.of<AppData>(context).tagsSavedLocally.length);
    TextEditingController editor = TextEditingController();
    String inputTag;

    return Scaffold(
      appBar: AppBar(
        title: Text("اهتماماتي"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Widget>>(
              future: _userTags,
              initialData: [LoadingWidget("Loading")],
              builder: (context, snapshot) {
                if (isTagsLoadedLocally()) {
                  return GridView.count(
                    crossAxisCount: 2,
                    children: Provider.of<AppData>(context, listen: true)
                        .tagsSavedLocally,
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  Provider.of<AppData>(context).tagsSavedLocally =
                      snapshot.data;
                         Provider.of<AppData>(context,listen: false).isTagslLoaded =
                      true;
                  return GridView.count(
                      crossAxisCount: 2, children: snapshot.data);
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return LoadingWidget("Loading");
                } else {
                  return Text("Error");
                }
              },
            ),
          ),
          // Expanded(
          //     child: GridView.count(crossAxisCount: 2, children: _userTags)),
          Container(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: editor,
                onChanged: (value) {
                  inputTag = value;
                },
                maxLength: 50,
                style: kHintTextStyle.copyWith(color: Colors.black),
                decoration: InputDecoration(
                    enabledBorder: kTextFieldBorder,
                    focusedBorder: kTextFieldBorder,
                    errorBorder: kTextFieldBorder,
                    fillColor: Colors.white,
                    hintText: 'Tag',
                    hintStyle: kHintTextStyle.copyWith(color: Colors.blueGrey),
                    contentPadding:
                        EdgeInsets.only(bottom: 40, left: 10, right: 10),
                    counterStyle: TextStyle(fontSize: 15, color: Colors.black)),
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              addTag(inputTag);
              // print(salfhTags.toString());
              editor.clear();
            },
            color: Colors.white,
            shape: StadiumBorder(
              side: BorderSide(color: Colors.white),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Add Tag",
                style: TextStyle(color: kMainColor, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
