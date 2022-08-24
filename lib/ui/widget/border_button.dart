import 'package:flutter/material.dart';

class BorderButtonLight extends StatelessWidget {
  BorderButtonLight(this.title, this.onPress,
      {this.margin, this.textStyle, this.borderColor = Colors.white54});

  final String title;
  final TextStyle textStyle;
  final EdgeInsetsGeometry margin;
  final Function onPress;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: InkWell(
            splashColor: borderColor,
            onTap: onPress,
            child: Container(
              alignment: Alignment.center,
              margin: margin,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border(
                  top: BorderSide(width: 1.0, color: borderColor),
                  left: BorderSide(width: 1.0, color: borderColor),
                  right: BorderSide(width: 1.0, color: borderColor),
                  bottom: BorderSide(width: 1.0, color: borderColor),
                ),
              ),
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle ?? TextStyle(color: Colors.white)),
            )));
  }
}
