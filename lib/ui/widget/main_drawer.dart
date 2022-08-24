import 'dart:async';

import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/pages/contest_create_page.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class MainDrawer extends StatelessWidget {
  Future<Null> _showCreateContest(BuildContext context) async {
    final Contest contest = await Navigator.of(context).push(
        new MaterialPageRoute<Contest>(
            settings: const RouteSettings(name: ContestCreatePage.routeName),
            builder: (BuildContext context) => ContestCreatePage()));
    if (contest != null) {
      WidgetUtils.showContestPage(context, contest,
          join: false, showComments: false);
    } else
      print("nessun contest creato");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey[50]),
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(bottom: 8.0, left: 16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: ClipOval(
                            child: new Container(
                                padding: EdgeInsets.all(1.0),
                                color: Colors.black26,
                                child: Avatar(
                                  shuttertop.currentSession.user
                                      .getImageUrl(ImageFormat.medium),
                                  size: 50.0,
                                  backColor: Colors.white,
                                  border: 2.0,
                                  shadow: 0.0,
                                  shadowColor: Colors.transparent,
                                )))),
                    Text(
                      shuttertop.currentSession.user.name,
                      style: TextStyle(
                          fontFamily: "Raleway",
                          fontSize: 15.0,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600,
                                fontFamily: "Raleway",
                                fontSize: 14.0,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: shuttertop.currentSession.user.score
                                            .toString() +
                                        " ",
                                    style: TextStyle(
                                        fontFamily: "Raleway",
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w700)),
                                TextSpan(
                                  text:
                                      "${AppLocalizations.of(context).punti} · ",
                                ),
                                TextSpan(
                                    text: shuttertop
                                            .currentSession.user.winnerCount
                                            .toString() +
                                        " ",
                                    style: TextStyle(
                                        fontFamily: "Raleway",
                                        color: Colors.grey[600])),
                                TextSpan(
                                  text: AppLocalizations.of(context).vittorie,
                                  style: TextStyle(fontFamily: "Raleway"),
                                ),
                              ],
                            )))
                  ]),
            ),
          ),
          MediaQuery.removePadding(
            context: context,
// DrawerHeader consumes top MediaQuery padding.
            removeTop: true,
            child: Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 8.0),
                children: <Widget>[
                  _elementRow(
                      AppLocalizations.of(context).ilTuoProfilo,
                      OMIcons.accountCircle,
                      () => WidgetUtils.showUserPage(
                          context, shuttertop.currentSession.user)),
                  _elementRow(
                      AppLocalizations.of(context).creaUnContest,
                      OMIcons.addCircleOutline,
                      () => _showCreateContest(context)),
                  _elementRow(
                      AppLocalizations.of(context).contestCreati,
                      Icons.filter,
                      () => WidgetUtils.showContestsCreatedPage(
                          context, shuttertop.currentSession.user)),
                  _elementRow(
                      AppLocalizations.of(context).gareInCorso,
                      Icons.timelapse,
                      () => WidgetUtils.showPhotoListPage(
                          context,
                          shuttertop.currentSession.user,
                          PhotosFetchType.inProgress)),
                  /*
                  new ListTile(
                    leading: new Icon(Ionicons.mail,
                      color: Colors.black54,
                    ),
                    title: new Text('Messaggi'),
                    onTap: (){},
                  ),*/
                  Divider(),
                  _elementRow(
                      AppLocalizations.of(context).impostazioni,
                      OMIcons.settings,
                      () => WidgetUtils.showSettingsPage(context))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _elementRow(String text, IconData icon, Function onTap) {
    return Material(
      child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.fromLTRB(30.0, 12.0, 0.0, 12.0),
            alignment: Alignment.centerLeft,
            child: Row(children: <Widget>[
              Container(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(
                    icon,
                    color: Colors.grey[600],
                  )),
              Text(
                text,
                style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: "Raleway",
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              )
            ]),
          )),
    );
  }
}
