import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';
import 'package:solif/models/AppData.dart';
import 'package:solif/screens/ChatScreen.dart';

final firestore = Firestore.instance;

class SalfhTile extends StatefulWidget {
  final String title;
  final String category;
  final String id;
  final Map colorsStatus;
  // add type (1 on 1, group)
  // change to stateful and add remaining slots

  SalfhTile({this.title, this.category, this.id, this.colorsStatus});

  @override
  _SalfhTileState createState() => _SalfhTileState();
}

class _SalfhTileState extends State<SalfhTile> {
  String colorName;
  List<Widget> dots = [];
  bool isFull = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateTileColor();
  }

  //gets color of tile
  updateTileColor() {
    String newColorName;
    widget.colorsStatus.forEach((name, value) {
      if (value == null) {
        newColorName = name;
      }
    });
    setState(() {
      //TODO: design full mode
      if (newColorName != null) {
        colorName = newColorName;
      } else {
        isFull = true;
      }
    });
  }

  List<Widget> generateDots(data) {
    List<Widget> newDots = [];
    data['colorsStatus'].forEach((name, id) {
      // if it's not the current user and someone is in the salfh with that color
      if (id != null && Provider.of<AppData>(context).currentUserID != id) {
        newDots.add(Padding(
          padding: const EdgeInsets.all(5.0),
          child: ColoredDot(kOurColors[name]),
        ));
      }
    });
    return newDots;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              title: this.widget.title,
              color: colorName,
              salfhID: this.widget.id,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: kOurColors[colorName],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.elliptical(10, 50),
                      bottomRight: Radius.elliptical(10, 50),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[850],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, left: 2),
                      child: StreamBuilder(
                          stream: firestore
                              .collection('Swalf')
                              .document(widget.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData)
                              return Row(
                                children: generateDots(snapshot.data),
                              );
                            return Padding(padding: EdgeInsets.all(5));
                          }),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: isFull
                    ? Row(
                        children: <Widget>[
                          Text(
                            "فل",
                            style: TextStyle(fontSize: 20),
                          ),
                          Icon(
                            Icons.close,
                            color: Colors.black,
                          )
                        ],
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
