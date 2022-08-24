import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/costants.dart';

class ButtonSubmit extends StatelessWidget {
  final Function onTap;
  final String text;
  final EdgeInsets padding;
  final double height;
  final double width;

  ButtonSubmit({
    this.onTap,
    this.text,
    this.padding,
    this.height = 36.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Container(
            height: height,
            width: width,
            padding: padding ??
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFDD2476),
                  const Color(0xFFFF512F),
                ], // whitish to gray
                tileMode:
                    TileMode.repeated, // repeats the gradient over the canvas
              ),
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: InkWell(
                splashColor: Colors.white70,
                onTap: onTap,
                child: Container(
                    alignment: Alignment.center,
                    child: Text(text,
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonFore))))));
  }
}
