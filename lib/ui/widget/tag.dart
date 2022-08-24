import 'package:flutter/material.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/ui/widget/tv_screen.dart';

class Tag extends StatelessWidget {
  const Tag(
      {this.value,
      this.keyTag,
      this.label,
      this.widgetIcon,
      this.iconSize,
      this.onTap,
      this.child,
      this.isHome = false,
      this.withBorder = false,
      Key key,
      this.icon})
      : super(key: key);

  final String value;
  final String label;
  final Widget child;
  final IconData icon;
  final double iconSize;
  final GlobalKey keyTag;
  final Function onTap;
  final bool isHome;
  final bool withBorder;
  final Widget widgetIcon;

  static final TextStyle numberStyle = TextStyle(
      color: Colors.grey[700], // Color(0xFF424242),
      fontWeight: FontWeight.w300,
      fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onTap,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: _tagHome())));
  }

  Widget _tagHome() {
    return TvScreen(
      100,
      Colors.white,
      Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.0,
                    fontFamily: "Raleway",
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w300)),
          ),
          Container(
            height: 1,
            color: Colors.grey[200],
            margin: EdgeInsets.only(left: 8, right: 8, top: 8),
          ),
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 4),
              child: child != null
                  ? child
                  : Text(
                      value,
                      key: keyTag,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Raleway",
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w300),
                    )),
        ],
      )),
      icon: icon,
    );
  }

  Widget _tag() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(bottom: 7.0),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Styles.subheader,
            )),
        child != null
            ? child
            : Text(
                value,
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w300),
              ),
      ],
    );
  }
}
