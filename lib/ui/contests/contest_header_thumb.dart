import 'package:flutter_svg/svg.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:flutter/material.dart';
import 'package:shuttertop/ui/contests/contest_details_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class ContestHeaderThumb extends StatelessWidget {
  ContestHeaderThumb(this.contest, {@required this.onTap});

  final Contest contest;
  final Function onTap;

  String _getContestImage() {
    try {
      return contest.getImageUrl(ImageFormat.normal);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Colors.white.withOpacity(0.85);
    final Widget award = new SvgPicture.asset(
      'assets/images/award.svg',
      color: color,
    );

    final Widget _content = Container(
      decoration: contest?.upload == null
          ? null
          : BoxDecoration(color: Colors.black.withOpacity(0.2)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 16.0, bottom: 16),
              height: 60,
              width: 60,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    top: 0,
                    child: Container(
                      height: 60,
                      width: 60,
                      child: award,
                    ),
                  ),
                  contest.category.id > 0
                      ? Container(
                          width: 40,
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Icon(
                            contest?.category?.icon,
                            size: 18.0,
                            color: color,
                          ))
                      : null,
                ].where((dynamic e) => e != null).toList(),
              )),
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 0, 0, 8.0),
            margin: EdgeInsets.only(bottom: 8, left: 16, right: 16),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: color, width: 1))),
            child: Text(
              (contest?.name ?? "").toUpperCase(),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 3,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28.0,
                  //fontFamily: "Raleway",
                  color: color),
            ),
          ),
          Container(
              margin: EdgeInsets.only(bottom: 16),
              child: ContestDetailsText(contest,
                  fontWeight: FontWeight.w900,
                  //fontFamily: "Raleway",
                  fontSize: 15.0,
                  fontColor: color)),
          /*_canJoinContest()
                        ? Container(
                            margin: EdgeInsets.only(top: 16.0),
                            child: new JoinButton(
                              onTap: onTap,
                              mode: JoinButtonMode.home,
                              text: contest.photosUser != null &&
                                      contest.photosUser.isNotEmpty
                                  ? AppLocalizations.of(context)
                                      .ripartecipa
                                      .toUpperCase()
                                  : AppLocalizations.of(context)
                                      .partecipa
                                      .toUpperCase(),
                            ))
                        : null*/
        ].where((Widget e) => e != null).toList(),
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      alignment: Alignment.center,
    );

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 0),
        //padding: EdgeInsets.symmetric(vertical: 42, horizontal: 16),
        height: 270,
        decoration: BoxDecoration(
          gradient: WidgetUtils.contestGradient1(contest),
        ),
        child: contest?.upload != null
            ? Container(
                child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: _getContestImage(),
                    fadeInDuration: Constants.fadeInDuration,
                    fit: BoxFit.cover,
                  ),
                  _content
                ],
              ))
            : _content);
  }
}
