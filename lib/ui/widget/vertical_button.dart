import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/costants.dart';

class VerticalButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final String text;
  final Function onTap;
  final Color color;

  VerticalButton(
      {@required this.icon,
      this.text,
      @required this.onTap,
      this.selected = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    final Color c =
        selected ? AppColors.brandPrimary : (color ?? Colors.grey[800]);
    return Material(
        color: Colors.transparent,
        child: InkWell(
          child: Container(
              child: text == null
                  ? Icon(
                      icon,
                      size: 20,
                      color: c,
                    )
                  : Column(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: Icon(
                              icon,
                              color: c,
                            )),
                        Text(text,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.0, color: c)),
                      ],
                    )),
          onTap: onTap,
        ));
  }
}
