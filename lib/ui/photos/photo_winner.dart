import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoWinner extends StatefulWidget {
  PhotoWinner(this.photo, this.onTap, this.onTapUser);

  final Photo photo;
  final ShowPhotoPage onTap;
  final ShowUserPage onTapUser;

  @override
  State createState() => new PhotoWinnerState();
}

class PhotoWinnerState extends State<PhotoWinner>
    with SingleTickerProviderStateMixin {
  Animation<Color> animationColor;
  AnimationController controllerColor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
              color: Colors.grey[800],
              padding: EdgeInsets.only(top: 12.0, bottom: 70.0),
              child: Container(
                  alignment: Alignment.center,
                  width: 130.0,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    AppLocalizations.of(context).winner.toUpperCase(),
                    style: new TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        fontSize: 24.0),
                  ))),
          Container(
              margin: EdgeInsets.only(top: 85.0),
              child: InkWell(
                onTap: () => widget.onTapUser(widget.photo.user),
                child: Avatar(
                  widget.photo.user.getImageUrl(ImageFormat.medium),
                  backColor: Colors.white,
                  border: 5.0,
                  shadow: 0.0,
                ),
              )),
        ],
      ),
      Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
          child: Text(
            widget.photo.user.name,
            style: TextStyle(
              fontSize: 24.0,
            ),
          )),
      Text(
          AppLocalizations.of(context)
              .nTop(widget.photo.votesCount)
              .toUpperCase(),
          style: new TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
          )),
      InkWell(
        onTap: () => widget.onTap(widget.photo),
        child: new Container(
          padding:
              EdgeInsets.only(bottom: 0.0, left: 0.0, right: 0.0, top: 24.0),
          child: FadeInImage(
            placeholder: new MemoryImage(kTransparentImage),
            image: new CachedNetworkImageProvider(
                widget.photo.getImageUrl(ImageFormat.normal)),
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 250),
          ),
        ),
      ),
    ]));
  }
}
