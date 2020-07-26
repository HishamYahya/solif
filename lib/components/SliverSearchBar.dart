import 'package:flutter/material.dart';

import '../constants.dart';

class SliverSearchBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final VoidCallback onScrollStretch;
  final expandableHeight;

  final Widget leadingWidget;

  const SliverSearchBar(
      {this.title,
      this.actions,
      this.onScrollStretch,
      this.leadingWidget,
      this.expandableHeight});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      sliver: SliverAppBar(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        onStretchTrigger: onScrollStretch,
        stretchTriggerOffset: 2, // testing
        // expandedHeight: expandableHeight ?? 56,
        centerTitle: true,
        // title: title,
        floating: true,
        snap: true,
        backgroundColor: Colors.white,
        // actions: actions,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: EdgeInsets.only(bottom: 2, right: 2, left: 2),
          title: Container(
            decoration: BoxDecoration(
              color: kMainColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kMainColor, width: 0),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        leading: leadingWidget,
      ),
    );
  }
}
