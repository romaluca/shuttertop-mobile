import 'dart:async';

import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meta/meta.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/contests/join_button.dart';
import 'package:shuttertop/ui/widget/rainbow_gradient.dart';
import 'package:shuttertop/ui/widget/ribbon.dart';
import 'package:shuttertop/ui/widget/vertical_button.dart';
import 'package:flutter/material.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class ContestHeader extends StatelessWidget {
  ContestHeader(
      {@required this.contest,
      @required this.onTapJoin,
      @required this.onTapRenew,
      @required this.onTapNewCover,
      this.opacity = 0.0,
      this.height,
      this.isLoading = false})
      : notify = new EntityNotification();

  final Contest contest;
  final double opacity;
  final Function onTapJoin;
  final Function onTapNewCover;
  final Function onTapRenew;
  final double height;
  final bool isLoading;
  final EntityNotification notify;

  Future<Null> _follow(BuildContext context) async {
    if (await shuttertop.activityRepository.contestFollow(contest))
      notify.dispatch(context);
  }

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
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final Widget award = new SvgPicture.asset(
      'assets/images/award.svg',
      color: Colors.white.withOpacity(0.8),
    );
    return Container(
      height: 356.0,
      color: Colors.white,
      margin: EdgeInsets.only(top: statusbarHeight),
      child: Stack(
        children: <Widget>[
          Container(
              height: 170,
              width: MediaQuery.of(context).size.width,
              // color: Colors.blueGrey,
              decoration: BoxDecoration(
                gradient: contest?.upload == null
                    ? WidgetUtils.contestGradient1(contest)
                    : null,
                color: contest?.upload == null ? null : Colors.grey[300],
              ),
              child: contest?.upload == null
                  ? Icon(
                      contest.category.icon,
                      size: 30.0,
                      color: Colors.white.withOpacity(0.8),
                    )
                  : FadeInImage(
                      placeholder: new MemoryImage(kTransparentImage),
                      image: new CachedNetworkImageProvider(_getContestImage()),
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 250),
                    )),
          contest?.upload == null
              ? Container(
                  margin: EdgeInsets.only(top: 50),
                  height: 80,
                  child: award,
                  alignment: Alignment.center,
                )
              : Container(),
          contest.isExpired
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                      height: 110.0,
                      width: 110.0,
                      child: Ribbon(
                        nearLength: 60,
                        farLength: 100,
                        title: 'TERMINATO!',
                        titleStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        color: Colors.redAccent,
                        location: RibbonLocation.topEnd,
                      )))
              : Container(),
          Container(
            height: 356.0,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              //borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(16.0),
                //height: 50.0,
                child: Opacity(
                  opacity: 1 - opacity,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        contest.category.id > 0
                            ? Padding(
                                padding: EdgeInsets.only(bottom: 3),
                                child: Text(
                                  contest.category.name.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey[800]),
                                ))
                            : Container(),
                        Container(
                          padding: EdgeInsets.only(bottom: 6.0),
                          alignment: Alignment.center,
                          child: Text(
                            contest.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: "Raleway",
                                fontWeight: FontWeight.w600,
                                fontSize: 24.0,
                                color: Colors.grey[700]),
                          ),
                        ),
                        _buildButtonJoin(context)
                      ]),
                ),
              )),
        ].where((Widget e) => e != null).toList(),
      ),
    );
  }

  Widget _buildButtonJoin(BuildContext context) {
    if (isLoading)
      return Container(
        height: 64.0,
        width: 10.0,
      );

    return Container(
        margin: EdgeInsets.only(top: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            contest.user.id != shuttertop.currentSession.user.id
                ? Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: PhysicalModel(
                        color: Colors.white,
                        elevation: 2,
                        borderRadius: BorderRadius.circular(25),
                        shadowColor: Colors.grey.withOpacity(0.3),
                        child: Container(
                            padding: EdgeInsets.all(12.0),
                            child: VerticalButton(
                              onTap: () => _follow(context),
                              //selected: contest.followed,
                              color: Colors.grey[700],
                              icon: contest.followed
                                  ? FontAwesomeIcons.solidBookmark
                                  : FontAwesomeIcons.bookmark,
                            ))))
                : Container(),
            !contest.isExpired
                ? JoinButton(
                    onTap: onTapJoin,
                    text: contest.photosUser != null &&
                            contest.photosUser.isNotEmpty
                        ? AppLocalizations.of(context).ripartecipa
                        : AppLocalizations.of(context).partecipa,
                    icon: OMIcons.addAPhoto,
                  )
                : JoinButton(
                    onTap: onTapRenew,
                    text: AppLocalizations.of(context).rilancia,
                    icon: FontAwesomeIcons.redo,
                  ),
            Padding(
                padding: EdgeInsets.only(left: 8),
                child: PhysicalModel(
                    color: Colors.white,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(25),
                    shadowColor: Colors.grey.withOpacity(0.3),
                    child: Container(
                        padding: EdgeInsets.all(12.0),
                        child: VerticalButton(
                          onTap: () => WidgetUtils.share(contest),
                          icon: FontAwesomeIcons.shareSquare,
                          color: Colors.grey[700],
                        )))),
          ].where((Widget e) => e != null).toList(),
        ));
  }
}
