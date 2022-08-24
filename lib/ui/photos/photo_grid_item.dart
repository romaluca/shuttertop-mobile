import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoGridItem extends StatelessWidget {
  PhotoGridItem(this.photo, this.onTap) : notify = new EntityNotification();

  final Photo photo;
  final ShowPhotoPage onTap;
  final EntityNotification notify;

  Future<Null> _vote(BuildContext context) async {
    if (await shuttertop.activityRepository.vote(photo))
      notify.dispatch(context);
    else
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(AppLocalizations.of(context).contestTerminato)));
  }

  Widget _avatarCircle() {
    try {
      return Container(
          child: Avatar(
        photo.user.getImageUrl(ImageFormat.thumb),
        border: 1.0,
        backColor: Colors.white.withOpacity(0.8),
        size: 30.0,
      ));
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
        footer: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: <Color>[Colors.transparent, Colors.black54],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(0.0, 0.9),
                  tileMode: TileMode.clamp)),
          child: GridTileBar(
              leading: photo.isWinner
                  ? Row(
                      children: <Widget>[
                        Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              color: Colors.white),
                          child: Icon(FontAwesomeIcons.handPeace),
                        ),
                        _avatarCircle()
                      ],
                    )
                  : _avatarCircle(),
              title: Text(photo.votesCount.toString(),
                  textAlign: TextAlign.right, style: TextStyle(fontSize: 16.0)),
              trailing: GestureDetector(
                onTap: () => _vote(context),
                child: Icon(
                  photo != null && photo.voted
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: (photo != null && photo.voted
                      ? Colors.redAccent
                      : Colors.white),
                ),
              )),
        ),
        child: GestureDetector(
            onTap: () => onTap(photo),
            child: FadeInImage(
              placeholder: new MemoryImage(kTransparentImage),
              image: new CachedNetworkImageProvider(
                  photo.getImageUrl(ImageFormat.thumb_small)),
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 250),
            )));
  }
}
