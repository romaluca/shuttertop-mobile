import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/user.dart';

class UserFollowBtn extends StatelessWidget {
  final User user;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double width;
  final EntityNotification notify;

  UserFollowBtn(this.user, {this.padding, this.width = 70.0, this.margin})
      : notify = new EntityNotification();

  Future<Null> _follow(BuildContext context) async {
    if (await shuttertop.activityRepository.userFollow(user))
      notify.dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    final Color c = user.followed ? AppColors.brandPrimary : Colors.grey[200];
    final Color cText =
        user.followed ? AppColors.brandPrimary : Colors.grey[700];
    return user != shuttertop.currentSession.user
        ? Container(
            margin: margin,
            child: InkWell(
                onTap: () => _follow(context),
                child: Container(
                  width: width,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 3.0),
                  padding: padding ??
                      EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: c, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Text(
                      user.followed
                          ? AppLocalizations.of(context).nonSeguire
                          : AppLocalizations.of(context).seguilo,
                      style: TextStyle(
                          color: cText,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0)),
                )),
          )
        : Container();
  }
}
