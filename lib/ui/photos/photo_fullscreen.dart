import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/ui/widget/image_zoomable.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
//import 'package:zoomable_image/zoomable_image.dart';
import 'package:shuttertop/ui/users/avatar.dart';

class PhotoFullscreen extends StatelessWidget {
  final Photo photo;
  final bool fullScreenInfo;
  final Function notifyFullScreen;
  final Function notifyFullScreenInfo;
  final Function notifyScaling;
  final ShowCommentsPage onTapAllComments;
  final ShowUserPage onTapUser;
  final EntityNotification notify;

  PhotoFullscreen({
    @required this.photo,
    @required this.fullScreenInfo,
    @required this.notifyFullScreen,
    @required this.notifyFullScreenInfo,
    @required this.notifyScaling,
    @required this.onTapAllComments,
    @required this.onTapUser,
  }) : notify = new EntityNotification();

  Future<Null> _vote(BuildContext context) async {
    if (await shuttertop.activityRepository.vote(photo))
      notify.dispatch(context);
    else
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(AppLocalizations.of(context).contestTerminato)));
  }

  String _getPhotoImage() {
    try {
      return photo.getImageUrl(ImageFormat.normal);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  String _getUserImage() {
    try {
      return photo.user.getImageUrl(ImageFormat.thumb);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap:
            notifyFullScreenInfo, // setState(() => fullScreenInfo = !fullScreenInfo),
        child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ImageZoomable(
                new CachedNetworkImageProvider(_getPhotoImage()),
                notifyScaling: (bool isScaling) => notifyScaling(isScaling),
                backgroundColor: Colors.white,
              ),
              fullScreenInfo
                  ? Positioned(
                      bottom: 0.0,
                      right: 0.0,
                      left: 0.0,
                      child: Container(
                          padding: EdgeInsets.only(bottom: 5.0, top: 8.0),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: <Color>[
                                Colors.white70,
                                Colors.white70
                              ],
                                  begin: FractionalOffset(0.0, 0.0),
                                  end: FractionalOffset(0.0, 1.0),
                                  tileMode: TileMode.clamp)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Row(children: <Widget>[
                                  IconButton(
                                      icon: Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.black87,
                                        size: 24.0,
                                      ),
                                      tooltip:
                                          AppLocalizations.of(context).commenta,
                                      onPressed: () => notifyFullScreen(
                                          callBack: () => onTapAllComments(
                                              photo,
                                              edit: true))),
                                  Container(
                                      margin:
                                          EdgeInsets.only(right: 0.0, top: 0.0),
                                      child: Text(
                                        photo.commentsCount.toString(),
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w300),
                                      )),
                                ]),
                                Row(children: <Widget>[
                                  IconButton(
                                    icon: Icon(
                                      photo != null && photo.voted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 24.0,
                                    ),
                                    tooltip: AppLocalizations.of(context).top,
                                    color: (photo != null && photo.voted
                                        ? Colors.redAccent
                                        : Colors.black87),
                                    onPressed: () => _vote(context),
                                  ),
                                  Container(
                                      margin:
                                          EdgeInsets.only(right: 0.0, top: 0.0),
                                      child: Text(
                                        photo.votesCount.toString(),
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w300),
                                      )),
                                ]),
                                IconButton(
                                  icon: Icon(
                                    Icons.share,
                                    color: Colors.black87,
                                    size: 24.0,
                                  ),
                                  tooltip:
                                      AppLocalizations.of(context).condividi,
                                  onPressed: () => WidgetUtils.share(photo),
                                ),
                              ])))
                  : null,
              fullScreenInfo
                  ? Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                          height: 62.0,
                          width: 200.0,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: <Color>[
                                Colors.white70,
                                Colors.white70
                              ],
                                  begin: FractionalOffset(0.0, 0.0),
                                  end: FractionalOffset(0.0, 1.0),
                                  tileMode: TileMode.clamp)),
                          padding: EdgeInsets.only(
                              top: 16.0, left: 12.0, bottom: 16.0),
                          child: Row(children: <Widget>[
                            Avatar(
                              _getUserImage(),
                              backColor: Colors.grey,
                              size: 32.0,
                            ),
                            Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(left: 12.0),
                                    child: InkWell(
                                      onTap: () => notifyFullScreen(
                                          callBack: () =>
                                              onTapUser(photo.user)),
                                      child: Text(photo.user?.name ?? "",
                                          style:
                                              TextStyle(color: Colors.black87)),
                                    ))),
                          ])))
                  : null,
              new Positioned(
                top: 0.0,
                right: 0.0,
                child: IconButton(
                    onPressed: notifyFullScreen,
                    icon: Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 24.0,
                    )),
              ),
            ].where((Widget e) => e != null).toList()));
  }
}
