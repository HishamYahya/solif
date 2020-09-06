import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: darkMode ? Colors.black : Colors.white,
        child: FutureBuilder(
          future: tagSearchFuture,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "صار شي غلط :( تأكد من نتك",
                  style: kHeadingTextStyle,
                ),
              );
            }
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Container(
                    child: Text(
                      "ابحث عن شي",
                      style:
                          kHeadingTextStyle.copyWith(color: Colors.grey[300]),
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
                            doc['tagCounter'].toString() + ' سالفة',
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
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'محد قد فتح سالفة عن ' + widget.searchTerm,
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
                                "صر اول واحد!",
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
