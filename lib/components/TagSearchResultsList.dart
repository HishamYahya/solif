import 'package:flutter/material.dart';

class TagSearchResultsList extends StatefulWidget {
  final String searchTerm;

  TagSearchResultsList({this.searchTerm});

  @override
  _TagSearchResultsListState createState() => _TagSearchResultsListState();
}

class _TagSearchResultsListState extends State<TagSearchResultsList> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('INITSTATE-----------------------------');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        controller: _scrollController,
        children: <Widget>[
          ListTile(
            title: Text(widget.searchTerm),
          ),
          ListTile(
            title: Text(widget.searchTerm),
          ),
          ListTile(
            title: Text(widget.searchTerm),
          ),
          ListTile(
            title: Text(widget.searchTerm),
          ),
          ListTile(
            title: Text(widget.searchTerm),
          ),
          ListTile(
            title: Text(widget.searchTerm),
          ),
          ListTile(
            title: Text(widget.searchTerm),
          ),
          ListTile(
            title: Text(widget.searchTerm),
          ),
        ],
      ),
    );
  }
}
