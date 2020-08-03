import 'package:flutter/material.dart';

import '../constants.dart';

class SliverSearchBar extends StatefulWidget {
  final FocusNode focusNode;

  final Function onChange;

  const SliverSearchBar({this.focusNode, this.onChange});

  @override
  _SliverSearchBarState createState() => _SliverSearchBarState();
}

class _SliverSearchBarState extends State<SliverSearchBar> {
  bool isFocused = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.focusNode.addListener(() {
      print(isFocused);
      setState(() {
        isFocused = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _onTap() async {
    if (!isFocused && !widget.focusNode.hasFocus) {
      setState(() {
        isFocused = true;
      });
      await Future.delayed(Duration(milliseconds: 1000));
      widget.focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      sliver: SliverAppBar(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        stretch: false,
        floating: true,
        snap: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: EdgeInsets.only(bottom: 0, right: 0, left: 0),
          title: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        widget.focusNode.unfocus();
                      },
                      splashColor: Colors.grey[100],
                      splashFactory: InkRipple.splashFactory,
                      child: Text(
                        "كنسل",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: IntrinsicWidth(
                                child: TextField(
                                  focusNode: widget.focusNode,
                                  onSubmitted: (value) {
                                    widget.focusNode.requestFocus();
                                  },
                                  onChanged: (value) {
                                    widget.onChange(value);
                                  },
                                  onTap: () {
                                    print('TAPPPEEDDD');
                                  },
                                  maxLength: 30,
                                  cursorRadius: Radius.circular(500),
                                  cursorColor: Colors.black,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    labelText:
                                        "ابحث عن الموضوع اللي تبي تسولف عنه",
                                    counterText: "",
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.bounceIn,
                      width: isFocused
                          ? MediaQuery.of(context).size.width * 0.15
                          : 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
