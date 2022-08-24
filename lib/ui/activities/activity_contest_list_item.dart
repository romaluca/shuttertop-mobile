import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/button_card.dart';
import 'package:shuttertop/ui/contests/contest_header_thumb.dart';

class ActivityContestListItem extends StatelessWidget {
  ActivityContestListItem(this.contest, this.onTap, this.onTapJoin)
      : notify = new EntityNotification();

  final Contest contest;
  final EntityNotification notify;
  final ShowObjectPage onTap;
  final ShowContestPage onTapJoin;

  Future<Null> _follow(BuildContext context) async {
    try {
      if (await shuttertop.activityRepository.contestFollow(contest))
        notify.dispatch(context);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  bool _canFollowContest() {
    try {
      return contest.user != shuttertop.currentSession.user;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  bool _canJoinContest() {
    try {
      return !contest.isExpired;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  bool _isFollowed() {
    try {
      return contest.followed;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      InkWell(
          onTap: () => onTap(contest),
          child: ContestHeaderThumb(
            contest,
            onTap: () => onTapJoin(contest, join: true),
          )),
      Container(
          padding:
              EdgeInsets.symmetric(horizontal: _canJoinContest() ? 16.0 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _canFollowContest()
                  ? ButtonCard(
                      icon: _isFollowed()
                          ? FontAwesomeIcons.solidBookmark
                          : FontAwesomeIcons.bookmark,
                      iconColor: Colors.grey[700],
                      onTap: () => _follow(context),
                      alignment:
                          _canJoinContest() ? MainAxisAlignment.start : null,
                      text: _isFollowed()
                          ? AppLocalizations.of(context).seguendo
                          : AppLocalizations.of(context).segui,
                    )
                  : null,
              _canJoinContest()
                  ? ButtonCard(
                      icon: OMIcons.cameraAlt,
                      onTap: () => onTapJoin(contest, join: true),
                      alignment: MainAxisAlignment.center,
                      iconSize: 24,
                      text: AppLocalizations.of(context).partecipa,
                    )
                  : null,
              ButtonCard(
                icon: FontAwesomeIcons.shareSquare,
                onTap: () => WidgetUtils.share(contest),
                alignment: _canJoinContest() ? MainAxisAlignment.end : null,
                text: AppLocalizations.of(context).condividi,
              ),
            ].where((Widget e) => e != null).toList(),
          )),
      /*AdmobBanner(
        adUnitId: 'ca-app-pub-3629337656411099/2781415127',
        adSize: AdmobBannerSize.SMART_BANNER,
      )*/
    ]);
  }
}
