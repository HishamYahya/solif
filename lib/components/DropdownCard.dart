import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:localstorage/localstorage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/LoadingWidget.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/models/Preferences.dart';

import '../constants.dart';

class DropdownCard extends StatefulWidget {
  final bool isOpen;
  final List tags;
  final String colorName;
  final String salfhID;

  DropdownCard({
    @required this.isOpen,
    @required this.tags,
    @required this.colorName,
    @required this.salfhID,
  });
  @override
  _DropdownCardState createState() => _DropdownCardState();
}

class _DropdownCardState extends State<DropdownCard>
    with TickerProviderStateMixin {
  bool isOpen = false;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    isOpen = this.isOpen;

    super.initState();
  }

  toggleMute() async {
    if (loading) return;
    bool isArabic = Provider.of<Preferences>(context, listen: false).isArabic;
    HttpsCallable callable =
        CloudFunctions.instance.getHttpsCallable(functionName: 'toggleMute');

    setState(() {
      loading = true;
    });
    print(widget.salfhID);

    try {
      await callable.call({'salfhID': widget.salfhID});
      toast(isArabic ? 'نجاح' : 'Success');
    } catch (e) {
      toast(isArabic ? 'فشل' : 'Failed');
    }
    if (mounted)
      setState(() {
        loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    // muted if id in array
    bool isMuted =
        Provider.of<AppData>(context).mutedSwalf.indexOf(widget.salfhID) != -1;
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 150),
      child: Container(
        decoration: BoxDecoration(
            color: Provider.of<Preferences>(context)
                .currentColors[widget.colorName],
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10))),
        constraints: widget.isOpen
            ? BoxConstraints(maxHeight: double.maxFinite)
            : BoxConstraints(maxHeight: 0),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            bottom: 16.0,
            right: 16.0,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(bottom: widget.tags.isEmpty ? 0 : 16.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      icon: Icon(
                        Icons.report,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: toggleMute,
                      visualDensity: VisualDensity.compact,
                      icon: loading
                          ? Container(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : Icon(
                              isMuted
                                  ? Icons.notifications_off
                                  : Icons.notifications_active,
                              color: Colors.white,
                            ),
                    ),
                  ],
                ),
              ),
              widget.tags.isNotEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Tags(
                        columns: 2,
                        itemCount: widget.tags.length,
                        itemBuilder: (index) {
                          final item = widget.tags[index];

                          return ItemTags(
                            // Each ItemTags must contain a Key. Keys allow Flutter to
                            // uniquely identify widgets.
                            key: Key(index.toString()),
                            index: index, // required
                            title: item,
                            activeColor: Colors.white,
                            color: Colors.white,

                            textStyle: TextStyle(
                              fontSize: 18,
                            ),
                            textActiveColor: Colors.grey[800],
                            textColor: Colors.grey[800],
                            splashColor: Colors.transparent,
                          );
                        },
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
