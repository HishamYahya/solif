import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:solif/Services/ValidFirebaseStringConverter.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';

import '../constants.dart';

class SliverSearchBar extends StatefulWidget {
  final FocusNode focusNode;

  final Function onChange;
  final Function(int) changeTabTo;
  final int curTab;

  final TextEditingController controller;

  const SliverSearchBar(
      {this.focusNode,
      this.onChange,
      this.controller,
      this.changeTabTo,
      this.curTab});

  @override
  _SliverSearchBarState createState() => _SliverSearchBarState();
}

class _SliverSearchBarState extends State<SliverSearchBar>
    with SingleTickerProviderStateMixin {
  Timer timer = Timer(Duration(milliseconds: 0), () => {});

  AnimationController _animationController;
  CurvedAnimation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCirc);

    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        _animationController.forward();
        widget.changeTabTo(1);
      }
    });
  }

  @override
  void didUpdateWidget(SliverSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.curTab == 0) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Provider.of<Preferences>(context).darkMode;
    bool isArabic = Provider.of<Preferences>(context).isArabic;
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      sliver: SliverAppBar(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        backgroundColor: darkMode ? Color(0XFF121212) : Colors.white,
        centerTitle: true,
        stretch: false,
        floating: true,
        snap: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: EdgeInsets.only(bottom: 0, right: 0, left: 0),
          title: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(widget.focusNode);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: darkMode ? Color(0XFF292929) : Colors.grey[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: widget.controller,
                                focusNode: widget.focusNode,
                                autofocus: false,
                                onSubmitted: (value) {
                                  widget.focusNode.requestFocus();
                                },
                                onChanged: (value) {
                                  timer.cancel();
                                  timer =
                                      Timer(Duration(milliseconds: 300), () {
                                    widget.onChange(value);
                                  });
                                },
                                maxLength: 30,
                                cursorRadius: Radius.circular(500),
                                cursorColor: Colors.black,
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                  color: darkMode
                                      ? kDarkModeTextColor87
                                      : Colors.grey[800],
                                  textBaseline: TextBaseline.alphabetic,
                                  fontSize: 18,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.transparent, width: 0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.transparent, width: 0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.transparent, width: 0),
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
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  labelText: isArabic
                                      ? "ابحث عن موضوع"
                                      : 'Search for topics',
                                  counterText: "",
                                  labelStyle: TextStyle(
                                    color: darkMode
                                        ? kDarkModeTextColor38
                                        : Colors.grey[800],
                                    textBaseline: TextBaseline.alphabetic,
                                    fontSize: 16,
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
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(_animation.value * 8.0),
                        child: InkWell(
                          onTap: () {
                            widget.onChange("");
                            widget.controller.clear();
                            Provider.of<AppData>(context, listen: false)
                                .searchTag = null;
                            widget.focusNode.unfocus();
                            widget.changeTabTo(0);
                          },
                          splashColor:
                              darkMode ? kDarkModeLightGrey : Colors.grey[100],
                          splashFactory: InkRipple.splashFactory,
                          child: AutoSizeText(
                            isArabic ? "كنسل" : 'Cancel',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                            textScaleFactor: _animation.value,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
