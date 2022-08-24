import 'package:flutter/material.dart';
import 'package:shuttertop/misc/costants.dart';

class CircleIconButton extends StatelessWidget {
  CircleIconButton(this.icon, this.onPressed,
      {this.margin, this.color, this.background = Colors.white});

  final IconData icon;
  final Function onPressed;
  final EdgeInsets margin;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Container(
          margin: margin,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.background, width: 1.0),
              shape: BoxShape.circle,
              color: background),
          child: Icon(
            icon,
            color: color,
            size: 20.0,
          ),
        ));
  }
}
