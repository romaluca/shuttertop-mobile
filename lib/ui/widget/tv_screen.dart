import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TvScreen extends StatelessWidget {
  TvScreen(this.width, this.color, this.child, {this.icon});

  final double width;
  final Color color;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final double height = width * 3 / 4;

    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: width - 10,
            height: height,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.elliptical(50, 10))),
          ),
          Container(
            width: width,
            height: height - 18,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.elliptical(10, 50))),
          ),
          icon != null
              ? Positioned(
                  right: (icon == FontAwesomeIcons.handPeace ? 10 : 5),
                  bottom: (icon == FontAwesomeIcons.handPeace ? 10 : 5),
                  child: Icon(
                    icon,
                    size:
                        height - (icon == FontAwesomeIcons.handPeace ? 30 : 20),
                    color: Colors.grey[50],
                  ))
              : Container(),
          Container(width: width - 10, height: height - 18, child: child)
          //Container(decoration: BoxDecoration(color: color), child: child)
        ],
      ),
    );
  }
}
