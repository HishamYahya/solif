import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;

  const CustomSliverAppBar({this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 50,
      centerTitle: true,
      title: title,
      floating: true,
      backgroundColor: Colors.white,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(),
    );
  }
}
