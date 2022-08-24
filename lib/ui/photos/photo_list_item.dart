import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/highlighted_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoListItem extends StatefulWidget {
  PhotoListItem({@required this.photo, @required this.onTap});

  final Photo photo;
  final ShowPhotoPage onTap;

  @override
  PhotoListItemState createState() => new PhotoListItemState();
}

class PhotoListItemState extends State<PhotoListItem> {
  bool showHeart = false;

  Future<Null> _vote(BuildContext context) async {
    if (await shuttertop.activityRepository.vote(widget.photo))
      setState(() => showHeart = widget.photo.voted);
    else
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(AppLocalizations.of(context).contestTerminato)));
  }

  Widget _avatarCircle() {
    return Avatar(
      widget.photo.user.getImageUrl(ImageFormat.thumb),
      border: 0.0,
      shadow: 0.5,
      backColor: Colors.white.withOpacity(0.8),
      size: 24.0,
    );
  }

  Widget _details(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 0),
        child: ClipRRect(
            borderRadius: new BorderRadius.circular(0.0),
            child: Container(
                decoration: const BoxDecoration(
                  gradient: const LinearGradient(
                    begin: const Alignment(0.0, 0.7),
                    end: const Alignment(0.0, -1.0),
                    colors: const <Color>[
                      const Color(0x00000000),
                      const Color(0x80000000),
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                    top: 8.0, bottom: 0, left: 12.0, right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _avatarCircle(),
                    widget.photo.isWinner
                        ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 28.0,
                              height: 28.0,
                              padding: EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 2.0),
                              child: Icon(
                                FontAwesomeIcons.handPeace,
                                color: Colors.white,
                              ),
                            ))
                        : Container(),
                    Expanded(child: Container()),
                    Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: Text(widget.photo.votesCount.toString(),
                            style: TextStyle(color: Colors.white))),
                    GestureDetector(
                      onTap: () => _vote(context),
                      child: Icon(
                        widget.photo != null && widget.photo.voted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: (widget.photo != null && widget.photo.voted
                            ? Colors.redAccent
                            : Colors.white),
                        size: 24.0,
                      ),
                    )
                  ],
                ))));
  }

  bool _onNotify(AnimationNotification notification) {
    setState(() => showHeart = false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.width *
        (widget.photo.width != null && widget.photo.height != null
            ? widget.photo.height / widget.photo.width
            : 0.6666);
    return Stack(children: <Widget>[
      Container(
          constraints: BoxConstraints(minHeight: height),
          color: Colors.white,
          child: ClipRRect(
              borderRadius: new BorderRadius.circular(0.0),
              child: GestureDetector(
                  onDoubleTap: () {
                    if (!widget.photo.voted) _vote(context);
                  },
                  onTap: () => widget.onTap(widget.photo),
                  child: FadeInImage(
                    placeholder: new MemoryImage(kTransparentImage),
                    image: new CachedNetworkImageProvider(
                        widget.photo.getImageUrl(ImageFormat.medium)),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    fadeInDuration: const Duration(milliseconds: 250),
                  )))),
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
      Container(height: 40, child: _details(context)),
    ]);
  }
}
