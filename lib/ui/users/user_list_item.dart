import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/misc/utils.dart';

class UserListItem extends StatelessWidget {
  UserListItem(this.user, this.onTap,
      {this.position = -1,
      this.format = UserListItemFormat.normal,
      this.margin})
      : notify = new EntityNotification();

  final User user;
  final int position;
  final ShowUserPage onTap;
  final EdgeInsets margin;
  final UserListItemFormat format;
  final EntityNotification notify;

  @override
  Widget build(BuildContext context) {
    String desc = "";
    String descFirst = "";
    int score;
    switch (format) {
      case UserListItemFormat.score:
        desc = "";
        descFirst = AppLocalizations.of(context).puntiWithScore(user.score);
        score = user.score;
        break;
      case UserListItemFormat.scoreMonth:
      case UserListItemFormat.scoreWeek:
        desc = "";
        descFirst =
            AppLocalizations.of(context).puntiWithScore(user.scorePartial);
        score = user.scorePartial;
        break;
      case UserListItemFormat.trophies:
        desc = "";
        descFirst =
            AppLocalizations.of(context).vittorieWithCount(user.winnerCount);
        break;
      default:
        desc =
            "${AppLocalizations.of(context).puntiWithScore(user.score)} · ${AppLocalizations.of(context).vittorieWithCount(user.winnerCount)} · ${AppLocalizations.of(context).photosWithCount(user.photosCount)}";
    }
    return InkWell(
        onTap: () => onTap(user),
        child: Container(
            margin: margin,
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5)),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      format != UserListItemFormat.normal &&
                              format != UserListItemFormat.minimal
                          ? Container(
                              alignment: Alignment.center,
                              constraints: BoxConstraints(minWidth: 45.0),
                              padding: EdgeInsets.only(right: 12.0),
                              child: Text("${position}th",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Raleway",
                                      color: Colors.grey[400],
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500)))
                          : null,
                      Container(
                        child: Avatar(
                          user.getImageUrl(ImageFormat.thumb_small),
                          backColor: Colors.grey,
                          size: UserListItemFormat.score != format &&
                                  UserListItemFormat.scoreWeek != format &&
                                  UserListItemFormat.scoreMonth != format
                              ? 40
                              : 24.0,
                          withFade: UserListItemFormat.score != format &&
                              UserListItemFormat.scoreWeek != format &&
                              UserListItemFormat.scoreMonth != format,
                        ),
                        padding: EdgeInsets.only(right: 16.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                child: UserListItemFormat.score == format ||
                                        format ==
                                            UserListItemFormat.scoreMonth ||
                                        format == UserListItemFormat.scoreWeek
                                    ? Text(user.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontFamily: "Raleway",
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0))
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Text(user.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                        fontFamily: "Raleway",
                                                        color: Colors.grey[700],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15.0))),
                                            descFirst != ""
                                                ? Row(
                                                    children: <Widget>[
                                                      Text(descFirst,
                                                          style:
                                                              Styles.subtitle),
                                                      Text(desc,
                                                          style:
                                                              Styles.subtitle)
                                                    ],
                                                  )
                                                : Text(desc,
                                                    style: Styles.subtitle),
                                          ])),
                          ],
                        ),
                      ),
                      format == UserListItemFormat.score ||
                              format == UserListItemFormat.scoreMonth ||
                              format == UserListItemFormat.scoreWeek
                          ? Text(score.toString() + "pts",
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  fontFamily: "Raleway",
                                  color: AppColors.brandPrimary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.0))
                          : Container()
                      //buildRight(context),
                    ].where((Widget e) => e != null).toList()))));
  }
}
