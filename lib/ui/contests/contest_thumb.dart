import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/widget/rainbow_gradient.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:transparent_image/transparent_image.dart';

enum ContestThumbType { microsquare, smallsquare, midsquare, horizontal }

class ContestThumb extends StatelessWidget {
  ContestThumb(this.contest, @required this.type, {this.margin})
      : super(key: new ObjectKey(contest));

  final Contest contest;
  final ContestThumbType type;
  final EdgeInsets margin;

  //final EdgeInsets margin;

  String _getContestImage() {
    try {
      return contest.getImageUrl(type == ContestThumbType.smallsquare ||
              type == ContestThumbType.microsquare ||
              type == ContestThumbType.midsquare
          ? ImageFormat.thumb_small
          : ImageFormat.medium);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  double getIconSize() {
    switch (type) {
      case ContestThumbType.smallsquare:
        return 16.0;
      case ContestThumbType.microsquare:
        return 16.0;
      case ContestThumbType.midsquare:
        return 20.0;
      case ContestThumbType.horizontal:
        return 30.0;
    }
    return 0;
  }

  double getAwardSize() {
    switch (type) {
      case ContestThumbType.smallsquare:
        return 40.0;
      case ContestThumbType.microsquare:
        return 40.0;
      case ContestThumbType.midsquare:
        return 60.0;
      case ContestThumbType.horizontal:
        return 80.0;
    }
    return 0;
  }

  BorderRadius getBorderRadiusRadius() {
    switch (type) {
      case ContestThumbType.horizontal:
        return BorderRadius.all(Radius.circular(8.0));
      default:
        return BorderRadius.all(Radius.circular(8.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget award = new SvgPicture.asset(
      'assets/images/award.svg',
      color: Colors.white.withOpacity(0.7),
    );
    final Widget thumb = new PhysicalModel(
        color: Colors.transparent,
        borderRadius: getBorderRadiusRadius(),
        clipBehavior: Clip.antiAlias,
        child: Container(
            constraints: BoxConstraints.expand(),
            //margin: margin,
            decoration: BoxDecoration(
                gradient: contest?.upload == null
                    ? WidgetUtils.contestGradient1(contest)
                    : null,
                color: contest?.upload == null ? null : Colors.grey[300]),
            child: contest?.upload == null
                ? Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          height: getAwardSize(),
                          width: getAwardSize(),
                          child: award,
                        ),
                      ),
                      contest.category.id > 0
                          ? Container(
                              width: 40,
                              padding: ContestThumbType.horizontal == type
                                  ? EdgeInsets.only(bottom: 14)
                                  : EdgeInsets.only(bottom: 8),
                              child: Icon(
                                contest.category.icon,
                                color: Colors.white.withOpacity(0.7),
                                size: getIconSize(),
                              ))
                          : Container()
                    ],
                  )
                : CachedNetworkImage(
                    imageUrl: _getContestImage(),
                    fadeInDuration: Constants.fadeInDuration,
                    fit: BoxFit.cover,
                  )));
    switch (type) {
      case ContestThumbType.smallsquare:
        return Container(
            width: 50.0, height: 50.0, child: thumb, margin: margin);
        break;
      case ContestThumbType.microsquare:
        return Container(
            width: 40.0, height: 40.0, child: thumb, margin: margin);
        break;
      case ContestThumbType.midsquare:
        return Container(
            width: 70.0, height: 70.0, child: thumb, margin: margin);
        break;
      case ContestThumbType.horizontal:
        return Container(height: 100.0, child: thumb, margin: margin);
        break;
    }
    return thumb;
  }
}
