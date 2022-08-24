import 'package:flutter/material.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/ui/widget/border_button.dart';

class Block extends StatelessWidget {
  const Block(
      {this.child,
      this.title,
      this.subtitle,
      this.height,
      this.onTapAll,
      this.titleViewAll = "Mostra tutti",
      this.color = Colors.white,
      this.padding = const EdgeInsets.only(bottom: 16.0),
      this.buttonMargin =
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      this.margin = const EdgeInsets.only(top: 16.0)});

  final Widget child;
  final String title;
  final String subtitle;
  final Color color;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final EdgeInsets buttonMargin;
  final Function onTapAll;
  final double height;
  final String titleViewAll;

  Widget _getTitle() {
    if (title == null) return Container();
    final TextStyle textStyle = TextStyle(
        fontSize: 18.0,
        fontFamily: "Raleway",
        color: Colors.grey[700],
        fontWeight: FontWeight.w800);

    return Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
        height: 50.0,
        alignment: Alignment.centerLeft,
        child: subtitle != null
            ? RichText(
                maxLines: 1,
                overflow: TextOverflow.fade,
                text: TextSpan(
                  style: textStyle,
                  children: <TextSpan>[
                    TextSpan(
                      text: title,
                      style: textStyle,
                    ),
                    TextSpan(
                        text: " · $subtitle",
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500))
                  ],
                ))
            : Text(
                title,
                style: textStyle,
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        color: color,
        padding: padding,
        child: Container(
            child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
          _getTitle(),
          Container(height: height, child: child),
          onTapAll != null
              ? BorderButtonLight(
                  titleViewAll,
                  onTapAll,
                  margin: buttonMargin,
                  borderColor: Colors.transparent,
                  textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800]),
                )
              : Container()
        ])));
  }
}
