import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/ui/activities/activity_contest_list_item.dart';
import 'package:shuttertop/ui/activities/activity_photo_list_item.dart';
import 'package:shuttertop/ui/activities/activity_text.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityListItem extends StatefulWidget {
  ActivityListItem(this.activity,
      {@required this.onTap,
      @required this.onTapAllComments,
      @required this.onTapUser,
      @required this.onTapJoin})
      : super(key: new ObjectKey(activity));

  final Activity activity;
  final ShowObjectPage onTap;
  final ShowCommentsPage onTapAllComments;
  final ShowContestPage onTapJoin;
  final ShowUserPage onTapUser;

  @override
  _ActivityListItemState createState() => new _ActivityListItemState();
}

class _ActivityListItemState extends State<ActivityListItem> {
  @override
  void initState() {
    super.initState();
  }

  bool _onNotify(EntityNotification notification) {
    setState(() {});
    return false;
  }

  bool _isPhotoListType() {
    try {
      return widget.activity.type == activityType.joined ||
          widget.activity.type == activityType.vote;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  bool _isFakeActivity() {
    try {
      return widget.activity.id == -1;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  String _getActivityUserImage() {
    try {
      return widget.activity.user.getImageUrl(ImageFormat.thumb);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFakeActivity()) return Container();
    return Container(
        child: Container(
            color: Colors.white,
            child: Column(children: <Widget>[
              Container(
                  padding: EdgeInsets.all(16.0),
                  child: Row(children: <Widget>[
                    InkWell(
                      onTap: () => WidgetUtils.showUserPage(
                          context, widget.activity?.user),
                      child: Avatar(
                        _getActivityUserImage(),
                        size: 40.0,
                        backColor: Colors.grey,
                      ),
                    ),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ActivityText(
                                  activity: widget.activity,
                                  onUserTap: widget.onTapUser,
                                  onActivityObjectTap: widget.onTap,
                                  margin: EdgeInsets.only(bottom: 3.0),
                                ),
                                Text(
                                    timeago.format(widget.activity?.insertedAt),
                                    style: TextStyle(color: Colors.grey[400]))
                              ],
                            )))
                  ])),
              new NotificationListener<EntityNotification>(
                  onNotification: _onNotify,
                  child: _isPhotoListType()
                      ? ActivityPhotoListItem(widget.activity?.photo,
                          widget.onTap, widget.onTapAllComments)
                      : ActivityContestListItem(widget.activity?.contest,
                          widget.onTap, widget.onTapJoin)),
              Container(
                height: 16,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                      Colors.grey[100],
                      Colors.grey[50],
                      Colors.grey[50].withOpacity(0.5),
                      Colors.grey[50],
                      Colors.grey[100]
                    ])),
              )
            ])));
  }
}
