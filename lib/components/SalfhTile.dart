import 'package:flutter/material.dart';
import 'package:solif/components/ColoredDot.dart';
import 'package:solif/constants.dart';
import 'package:solif/screens/ChatScreen.dart';

class SalfhTile extends StatelessWidget {
  final String title;
  final String color;
  final String category;
  final bool disabled;
  // add type (1 on 1, group)
  // change to stateful and add remaining slots

  SalfhTile({this.title, this.color, this.category, this.disabled});

  @override
  Widget build(BuildContext context) {
    final Color tileColor = kOurColors[color];

    List<Widget> generateDots() {
      List<Widget> dots = [];
      kOurColors.forEach((key, value) {
        if (key != color) {
          dots.add(Padding(
            padding: const EdgeInsets.all(5.0),
            child: ColoredDot(value),
          ));
        }
      });
      return dots;
    }

    return GestureDetector(
      onTap: () {
        if (!disabled)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                title: this.title,
                color: this.color,
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
            color: tileColor,
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
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[850],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0, left: 2),
                      child: Row(
                        children: generateDots(),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
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
