import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/ValidFirebaseStringConverter.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/components/SliverSearchBar.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';

final Firestore firestore = Firestore.instance;

class TagSearchResultsList extends StatefulWidget {
  final String searchTerm;
  final TextEditingController searchFieldController;

  final Function(int) changeTabTo;
  final int curTab;
  TagSearchResultsList(
      {this.searchTerm,
      this.searchFieldController,
      this.changeTabTo,
      this.curTab});

  @override
  _TagSearchResultsListState createState() => _TagSearchResultsListState();
}

class _TagSearchResultsListState extends State<TagSearchResultsList> {
  ScrollController _scrollController = ScrollController();
  Future<QuerySnapshot> tagSearchFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.searchTerm != '') {
      tagSearchFuture = Firestore.instance
          .collection('tags')
          .where('searchKeys', arrayContains: widget.searchTerm)
          .orderBy('tagCounter', descending: true)
          .limit(10)

          // .orderBy('tagName', descending: true)
          // .where('tagName', isGreaterThanOrEqualTo: searchkey)
          // .where('tagName', isLessThan: searchkey + 'z')

          // .startAt([searchkey])
          // .endAt([searchkey + '\uf8ff'])
          .getDocuments();
    } else {
      tagSearchFuture = null;
    }
  }

  @override
  void didUpdateWidget(TagSearchResultsList oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.searchTerm != '') {
      tagSearchFuture = Firestore.instance
          .collection('tags')
          .where('searchKeys', arrayContains: widget.searchTerm)
          .orderBy('tagCounter', descending: true)
          .limit(10)

          // .orderBy('tagName', descending: true)
          // .where('tagName', isGreaterThanOrEqualTo: searchkey)
          // .where('tagName', isLessThan: searchkey + 'z')

          // .startAt([searchkey])
          // .endAt([searchkey + '\uf8ff'])
          .getDocuments();
    } else {
      tagSearchFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    bool isValidString = ValidFireBaseStringConverter.generalValidStrings
        .hasMatch(widget.searchTerm);
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        color: darkMode ? Colors.black : Colors.white,
        child: FutureBuilder(
          future: tagSearchFuture,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  isArabic
                      ? "صار شي غلط :( تأكد من نتك"
                      : "Something went wrong",
                  style: kHeadingTextStyle,
                ),
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Container(
                    child: Text(
                      isArabic ? "ابحث عن شي" : 'Search for a topic',
                      style: TextStyle(
                        color:
                            darkMode ? kDarkModeTextColor38 : Colors.grey[300],
                        fontSize: 22,
                      ),
                    ),
                  ),
                );
              case ConnectionState.waiting:
                return Center(
                  child: LoadingWidget(""),
                );
              case ConnectionState.done:
                if (snapshot.hasData && snapshot.data.documents.length != 0) {
                  final List<DocumentSnapshot> docs = snapshot.data.documents;
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
                          onTap: () {
                            Provider.of<AppData>(context, listen: false)
                                .searchTag = doc['tagName'];
                            widget.searchFieldController.text = doc['tagName'];
                            widget.changeTabTo(0);
                            FocusScope.of(context).unfocus();
                          },
                          shape: BeveledRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      );
                    },
                  );
                } else if (isValidString) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          (isArabic
                                  ? 'محد قد فتح سالفة عن '
                                  : 'No one chatted about ') +
                              widget.searchTerm +
                              (!isArabic ? ' yet' : ''),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Material(
                          color: kMainColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                            onTap: () => print('dfg'),
                            splashColor: Colors.white,
                            splashFactory: InkSplash.splashFactory,
                            canRequestFocus: true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16),
                              child: Text(
                                isArabic ? "صر اول واحد!" : "Be the first!",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: AutoSizeText(
                      isValidString || widget.searchTerm.isEmpty
                          ? null
                          : isArabic
                              ? 'المواضيع لازم مكونة من حروف, أرقام, أو _'
                              : 'Topics can only contain letters, numbers, and the _ character',
                      style: TextStyle(
                        color: kCancelRedColor,
                      ),
                      maxLines: 2,
                    ),
                  );
                }
                break;
              default:
                return Container(
                  child: Text('sodiufhsdoifh'),
                );
            }
            ;
          },
        ),
      ),
    );
  }
}
