import 'package:flutter/material.dart';
import 'package:shuttertop/misc/costants.dart';

class IconBadge extends StatelessWidget {
  IconBadge(this.icon, this.enabled);

  final bool enabled;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return enabled
        ? Stack(
            children: <Widget>[
              Icon(icon),
              Container(
                margin: EdgeInsets.only(left: 12.0),
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                ),
              )
            ],
          )
        : Icon(icon);
  }
}
