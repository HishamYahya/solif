import 'package:flutter/material.dart';

import '../constants.dart';

class CustomSliverAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final VoidCallback onScrollStretch;

  const CustomSliverAppBar({this.title, this.actions, this.onScrollStretch});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      onStretchTrigger: onScrollStretch,
      stretchTriggerOffset: 2, // testing
      expandedHeight: 50,
      centerTitle: true,
      title: title,
      floating: true,
      backgroundColor: kMainColor,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(),
    );
  }
}
