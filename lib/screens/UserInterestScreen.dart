import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/OurErrorWidget.dart';
import 'package:solif/components/SliverSearchBar.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/TagTile.dart';
import 'package:solif/models/AppData.dart';
import 'package:flutter_tags/flutter_tags.dart';

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
    int ind = 0; 
    print("?XD");
    await firestore
        .collection("users")
        .document(userID)
        .collection('userTags')
        .orderBy('timeAdded')
        .getDocuments()
        .then((value) {
      for (var doc in value.documents.reversed) {
        tags.add(TagTile(
          tagName: doc['tagName'],
          key: Key(ind.toString()),
          index: ind++
        ));
      }
    });
    return tags;
  }

  Widget renderLocalTags() {
    List<TagTile> _tags =
        Provider.of<AppData>(context, listen: true).tagsSavedLocally;
    return Center(
      child: Tags(
        // alignment: WrapAlignment.center,
        columns: 3,
        
        // symmetry: true,
        // heightHorizontalScroll: 2,
        // spacing: 10,
        itemCount: _tags.length,
        textField: TagsTextField(onChanged: (string) => print(string),onSubmitted:  (inputTag) {
          addTag(inputTag);
        },),
          
        
        itemBuilder: (index) {
          _tags[index].index = index;  
          return _tags[index];
        },
      ),
    );
  }

  void saveLocalTagsLocally(snapshot) {
    Provider.of<AppData>(context).tagsSavedLocally = snapshot.data;
    Provider.of<AppData>(context, listen: false).isTagslLoaded = true;
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
      body:
          FutureBuilder<List<Widget>>(
            future: _userTags,
            initialData: [LoadingWidget("Loading")],
            builder: (context, snapshot) {
              if (isTagsLoadedLocally()) {
                return renderLocalTags();
              } else if (snapshot.connectionState == ConnectionState.done) {
                saveLocalTagsLocally(snapshot);
                return renderLocalTags();
              } else if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return LoadingWidget("Loading");
              } else {
                return OurErrorWidget(errorMessage: 'Error',);
              }
            },
          ),
          // Expanded(
          //     child: GridView.count(crossAxisCount: 2, children: _userTags)),
          
    );
  }
}
