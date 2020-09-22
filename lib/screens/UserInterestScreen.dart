// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:solif/components/OurErrorWidget.dart';
// import 'package:solif/components/SliverSearchBar.dart';
// import 'package:solif/components/LoadingWidget.dart';
// import 'package:solif/components/TagChip.dart';
// import 'package:solif/models/AppData.dart';
// import 'package:flutter_tags/flutter_tags.dart';
// import 'package:solif/models/AppData.dart';

// import '../constants.dart';

// class UserInterestScreen extends StatefulWidget {
//   @override
//   _UserInterestScreenState createState() => _UserInterestScreenState();
// }

// class _UserInterestScreenState extends State<UserInterestScreen> {
//   final _fcm = FirebaseMessaging();
//   Future<List<TagChip>> _userTags;

//   initState() {
//     if (!isTagsLoadedLocally()) {
//       print("not loaded");
//       _userTags = getInterests();
//     } else {
//       _userTags = null;
//     }

//     super.initState();
//   }

//   bool isTagsLoadedLocally() {
//     return Provider.of<AppData>(context, listen: false).isTagsLoadedLocally();
//   }

//   void cancelTag(String tag) {
//     Provider.of<AppData>(context, listen: false).deleteTag(tag);
//   }

//   void addTag(String tag) {
//     Provider.of<AppData>(context, listen: false).addTag(tag);
//   }

//   Future<List<TagChip>> getInterests() async {
//     final firestore = Firestore.instance;
//     String userID = Provider.of<AppData>(context, listen: false).currentUserID;
//     List<TagChip> tags = [];
//     int ind = 0;
//     print("?XD");
//     await firestore
//         .collection("users")
//         .document(userID)
//         .collection('userTags')
//         .orderBy('timeAdded')
//         .getDocuments()
//         .then((value) {
//       // for (var doc in value.documents.reversed) {
//       //   tags.add(TagTile(
//       //       tagName: doc['tagName'], key: Key(ind.toString()), index: ind++));
//       // }
//     });
//     return tags;
//   }

//   Widget renderLocalTags() {
//     List<TagChip> _tags =
//         Provider.of<AppData>(context, listen: true).tagsSavedLocally;
//     return Center(
//       child: Tags(
//         // alignment: WrapAlignment.center,
//         columns: 3,
//         alignment: WrapAlignment.start,
//         horizontalScroll: true,

//         // symmetry: true,
//         // heightHorizontalScroll: 2,
//         // spacing: 10,
//         //direction: Axis.horizontal,
//         verticalDirection: VerticalDirection.up,
//         itemCount: _tags.length,
//         textField: TagsTextField(),

//         itemBuilder: (index) {
//           // _tags[index].index = index;
//           return _tags[_tags.length - 1 - index];
//         },
//       ),
//     );
//   }

//   void saveLocalTagsLocally(snapshot) {
//     Provider.of<AppData>(context).tagsSavedLocally = snapshot.data;
//     Provider.of<AppData>(context, listen: false).isTagslLoaded = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(_userTags);
//     //print(Provider.of<AppData>(context).tagsSavedLocally.length);
//     TextEditingController editor = TextEditingController();
//     String inputTag;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("اهتماماتي"),
//         backgroundColor: kMainColor,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Text(
//             "هنا نحفظ اهتماماتك, فيه شي تبي تسولف عنه مع احد؟ ضفه هنا وراح نعلمك اذا احد يبي يسولف",
//             style: TextStyle(
//               fontSize: 20,
//               color: kDarkTextColor,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           FutureBuilder<List<Widget>>(
//             future: _userTags,
//             initialData: [LoadingWidget("Loading")],
//             builder: (context, snapshot) {
//               if (isTagsLoadedLocally()) {
//                 return renderLocalTags();
//               } else if (snapshot.connectionState == ConnectionState.done) {
//                 saveLocalTagsLocally(snapshot);

//                 return renderLocalTags();
//               } else if (snapshot.connectionState == ConnectionState.waiting) {
//                 return LoadingWidget("Loading");
//               } else {
//                 return OurErrorWidget(
//                   errorMessage: 'Error',
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       // Expanded(
//       //     child: GridView.count(crossAxisCount: 2, children: _userTags)),
//     );
//   }

//   getTextField() {
//     return TagsTextField(
//       textStyle: TextStyle(
//         fontSize: 18,
//         color: Colors.black,
//       ),
//       autofocus: false,
//       hintText: 'مين تبي نعلم؟',
//       hintTextColor: Colors.black54,
//       suggestionTextColor: Colors.black54,
//       constraintSuggestion: false,
//       // suggestions: suggestions,
//       // onChanged: (searchkey) {
//       //   getSuggestion(searchkey);
//       // },
//       inputDecoration: InputDecoration(
//         enabledBorder: kTextFieldBorder,
//         focusedBorder: kTextFieldBorder,
//         errorBorder: kTextFieldBorder,
//         fillColor: Colors.white,
//         hintStyle: kHintTextStyle,
//         contentPadding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
//         counterStyle: TextStyle(fontSize: 15, color: Colors.white),
//       ),
//       onSubmitted: (String inputTag) {
//         // Add item to the data source.
//         addTag(inputTag);
//       },
//     );
//   }
// }
