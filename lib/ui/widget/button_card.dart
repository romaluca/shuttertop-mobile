import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/utils.dart';

class ButtonCard extends StatelessWidget {
  ButtonCard({
    @required this.icon,
    @required this.text,
    @required this.onTap,
    this.iconSize = 20,
    this.alignment = MainAxisAlignment.center,
    this.iconColor,
  });

  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String text;
  final MainAxisAlignment alignment;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: alignment ?? MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Icon(
                          icon,
                          size: iconSize,
                          color: iconColor ?? Colors.grey[600],
                        ),
                        margin: EdgeInsets.only(right: 8.0),
                      ),
                      Text(
                        Utils.capitalize(text),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Raleway",
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )),
              onTap: onTap,
            )));
  }
}
