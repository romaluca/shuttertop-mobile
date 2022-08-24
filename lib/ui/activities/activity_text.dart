import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/activity.dart';

class ActivityText extends StatelessWidget {
  ActivityText(
      {@required this.activity,
      this.onUserTap,
      this.onActivityObjectTap,
      this.margin}) {
    if (onUserTap != null) userTap.onTap = () => onUserTap(activity.user);
    if (onActivityObjectTap != null)
      objectTap.onTap = () => onActivityObjectTap(activity.getObject());
  }

  final Activity activity;
  final ShowUserPage onUserTap;
  final ShowObjectPage onActivityObjectTap;
  final EdgeInsets margin;
  final TapGestureRecognizer userTap = TapGestureRecognizer();
  final TapGestureRecognizer objectTap = TapGestureRecognizer();

  bool _isCurrentUserActivity() {
    try {
      return activity.user == shuttertop.currentSession.user;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: margin,
        child: RichText(
            maxLines: 3,
            overflow: TextOverflow.fade,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: "Raleway",
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600),
              children: <TextSpan>[
                _isCurrentUserActivity()
                    ? null
                    : TextSpan(
                        recognizer: userTap.onTap != null ? userTap : null,
                        text: activity.user.name),
                TextSpan(
                    text:
                        activity.getActionName(shuttertop.currentSession?.user),
                    style: new TextStyle(color: Colors.grey[600])),
                TextSpan(
                  text: activity.getObjectName(shuttertop.currentSession?.user),
                  recognizer: objectTap.onTap != null ? objectTap : null,
                ),
              ].where((TextSpan e) => e != null).toList(),
            )));
  }
}
