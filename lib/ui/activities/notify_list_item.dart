import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/ui/activities/activity_text.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/contests/contest_thumb.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class NotifyListItem extends StatelessWidget {
  NotifyListItem(this.activity, this.onTap)
      : super(key: new ObjectKey(activity));

  final Activity activity;
  final int userId = new ShuttertopApp().currentSession.user.id;
  final ShowActivityObjectPage onTap;

  Widget _getImageThumb() {
    try {
      final EntityBase entity = activity.getSubject();
      if (entity is User)
        return Avatar(entity.getImageUrl(ImageFormat.thumb),
            backColor: Colors.grey, size: 50.0);
      else if (entity is Contest)
        return ContestThumb(entity, ContestThumbType.smallsquare);
      else if (entity is Photo)
        return Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                    entity.getImageUrl(ImageFormat.thumb_small))),
          ),
        );
      else
        return Container();
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return Container();
    }
  }

  bool _isWithPoints() {
    try {
      return activity.points != null && activity.points > 0;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //String imageUrl = activity.getImageUrl();
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () => onTap(activity), // () => _showObjectPage(context),
            child: Container(
                padding: EdgeInsets.all(0.0),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 0.0),
                    ),
                    child: Column(children: <Widget>[
                      Container(
                          padding: EdgeInsets.all(16.0),
                          child: Row(children: <Widget>[
                            _getImageThumb(),
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(
                                              right: 10.0, bottom: 5.0),
                                          child: ActivityText(
                                            activity: activity,
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                              timeago
                                                  .format(activity.insertedAt),
                                              style: TextStyle(
                                                  color: Colors.grey[400])),
                                          //activity.userTo.id == userId &&
                                        ]
                                            .where((Widget t) => t != null)
                                            .toList(),
                                      )
                                    ],
                                  )),
                            ),
                            _isWithPoints()
                                ? Container(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            "+${activity.points}",
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.grey[700]),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 3.0),
                                              child: Text(
                                                AppLocalizations.of(context)
                                                    .punti,
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontFamily: "Raleway",
                                                    color: Colors.grey[400]),
                                              )),
                                        ]))
                                : Container(),
                          ])),
                    ])))));
  }
}
