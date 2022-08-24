import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/ui/widget/tag.dart';
import 'package:shuttertop/pages/notifies_page.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class UserStats extends StatelessWidget {
  UserStats(this.user,
      {this.isHome = false, this.keyWins, this.keyScore, this.keyInProgress});

  final User user;
  final bool isHome;

  final GlobalKey keyWins;
  final GlobalKey keyScore;
  final GlobalKey keyInProgress;

  @override
  Widget build(BuildContext context) {
    final Widget award = new SvgPicture.asset(
      'assets/images/award.svg',
      color: Colors.grey[800],
    );
    final Widget divider = null;
    /*isHome
        ? Container(
            color: Colors.grey[100],
            width: 1,
            height: 36.0,
          )
        : null;*/
    return Container(
      padding: EdgeInsets.symmetric(vertical: isHome ? 0.0 : 12.0),
      //color: Colors.white,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Tag(
                    key: keyScore,
                    value: user.score.toString(),
                    label: AppLocalizations.of(context).punti.toLowerCase(),
                    isHome: isHome,
                    icon: OMIcons.whatshot,
                    iconSize: 20,
                    onTap: () {
                      _showScorePage(context);
                    })),
            Expanded(
                child: Tag(
                    key: keyWins,
                    value: user.winnerCount.toString(),
                    label: AppLocalizations.of(context).vittorie.toLowerCase(),
                    isHome: isHome,
                    icon: FontAwesomeIcons.handPeace,
                    iconSize: 18,
                    onTap: () {
                      _showPhotoListPage(context, PhotosFetchType.wins);
                    })),
            Expanded(
                child: Tag(
                    key: keyInProgress,
                    value: user.inProgress.toString(),
                    label: AppLocalizations.of(context).inGara.toLowerCase(),
                    isHome: isHome,
                    icon: Icons.timelapse,
                    iconSize: 20,
                    onTap: () {
                      _showPhotoListPage(context, PhotosFetchType.inProgress);
                    })),
          ].where((Widget e) => e != null).toList()),
    );
  }

  void _showPhotoListPage(BuildContext context, PhotosFetchType type) {
    WidgetUtils.showPhotoListPage(context, user, type);
  }

  void _showScorePage(BuildContext context) async {
    print("_photoPhotoListPage");
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: NotifiesPage.routeName),
            builder: (BuildContext context) =>
                NotifiesPage(user, type: ActivityFetchType.score)));
  }
}
