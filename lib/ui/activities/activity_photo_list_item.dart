import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/ui/widget/highlighted_icon.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/ui/widget/button_card.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class ActivityPhotoListItem extends StatefulWidget {
  final Photo photo;
  final ShowObjectPage onTap;
  final ShowCommentsPage onTapAllComments;
  final EntityNotification notify;

  ActivityPhotoListItem(this.photo, this.onTap, this.onTapAllComments)
      : notify = new EntityNotification();

  @override
  ActivityPhotoListItemState createState() => new ActivityPhotoListItemState();
}

class ActivityPhotoListItemState extends State<ActivityPhotoListItem> {
  bool showHeart = false;

  Future<Null> _vote(BuildContext context) async {
    try {
      if (await shuttertop.activityRepository.vote(widget.photo)) {
        showHeart = widget.photo.voted;
        widget.notify.dispatch(context);
      } else
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text(AppLocalizations.of(context).contestTerminato)));
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  bool _onNotify(AnimationNotification notification) {
    try {
      setState(() => showHeart = false);
      return false;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  bool _isVoted() {
    try {
      return widget.photo.voted;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  String _getSubtitle() {
    try {
      return AppLocalizations.of(context).topVis(widget.photo.votesCount);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  String _getCommentSubtitle() {
    try {
      return AppLocalizations.of(context)
          .commentiVis(widget.photo.commentsCount);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  String _getPhotoImage() {
    try {
      return widget.photo.getImageUrl(ImageFormat.normal);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = widget.photo.getImageHeight(context);
    return Column(
      children: <Widget>[
        InkWell(
            onDoubleTap: () {
              if (!_isVoted()) _vote(context);
            },
            onTap: () => WidgetUtils.showPhotoPage(context, widget.photo,
                showComments: false),
            child: Column(children: <Widget>[
              Stack(children: <Widget>[
                PhysicalModel(
                  color: AppColors.placeHolder,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    height: height ?? 400,
                    child: CachedNetworkImage(
                      fadeInDuration: Constants.fadeInDuration,
                      imageUrl: _getPhotoImage(),
                    ),
                  ),
                ),
                showHeart
                    ? Positioned(
                        top: 0.0,
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: NotificationListener<AnimationNotification>(
                            onNotification: _onNotify,
                            child: HighLightedIcon(
                              Icons.favorite,
                              color: Colors.white70,
                              size: 150.0,
                            )))
                    : Container(),
              ]),
            ])),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ButtonCard(
                  icon: FontAwesomeIcons.comment,
                  onTap: () =>
                      widget.onTapAllComments(widget.photo, edit: true),
                  alignment: MainAxisAlignment.start,
                  text: AppLocalizations.of(context).commenta,
                ),
                ButtonCard(
                  icon: _isVoted()
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  iconColor: (_isVoted() ? Colors.redAccent : Colors.grey[600]),
                  onTap: () => _vote(context),
                  text: AppLocalizations.of(context).top,
                ),
                ButtonCard(
                  icon: FontAwesomeIcons.shareSquare,
                  onTap: () => WidgetUtils.share(widget.photo),
                  alignment: MainAxisAlignment.end,
                  text: AppLocalizations.of(context).condividi,
                ),
              ],
            )),
        widget.photo.votesCount == 0
            ? Container()
            : InkWell(
                onTap: () => widget.onTapAllComments(widget.photo, edit: false),
                child: Container(
                    margin: EdgeInsets.only(left: 16.0, bottom: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _getSubtitle(),
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                    ))),
        widget.photo.commentsCount == 0
            ? Container()
            : InkWell(
                onTap: () => widget.onTapAllComments(widget.photo, edit: false),
                child: Container(
                    margin: EdgeInsets.only(left: 16.0),
                    padding: EdgeInsets.only(top: 8.0, bottom: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _getCommentSubtitle(),
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                    ))),
      ],
    );
  }
}
