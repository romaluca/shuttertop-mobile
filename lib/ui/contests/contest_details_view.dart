import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/users/user_list_item.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:translator/translator.dart';

class ContestDetailsView extends StatefulWidget {
  const ContestDetailsView(this.contest, this.onTapUser, {Key key})
      : super(key: key);

  final Contest contest;
  final ShowUserPage onTapUser;
  @override
  _ContestDetailsViewState createState() => new _ContestDetailsViewState();
}

class _ContestDetailsViewState extends State<ContestDetailsView> {
  bool translated = false;
  String translate = "";

  bool _onNotify(EntityNotification notification) {
    setState(() {});
    return false;
  }

  int _getContestEdition() {
    try {
      return widget.contest.edition;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return 1;
    }
  }

  void _onTapTranslate() async {
    final GoogleTranslator translator = GoogleTranslator();
    if (!translated) {
      translate = await translator.translate(widget.contest?.description,
          to: shuttertop.currentSession.user?.language);
    }
    setState(() {
      translated = !translated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        Block(
          margin: EdgeInsets.only(top: 1.0),
          title: AppLocalizations.of(context).dettagli,
          child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        AppLocalizations.of(context)
                            .nEdizione(_getContestEdition()),
                        style: TextStyle(color: Colors.black.withOpacity(0.7))),
                    Text(
                      (translated ? translate : widget.contest?.description) ??
                          "",
                      style: TextStyle(color: Colors.black.withOpacity(0.7)),
                    ),
                    widget.contest.user.language !=
                            shuttertop.currentSession.user.language
                        ? Container(
                            margin: EdgeInsets.only(top: 5.0),
                            child: InkWell(
                                onTap: _onTapTranslate,
                                child: Text(
                                  translated
                                      ? "Nascondi traduzione"
                                      : "Visualizza traduzione",
                                  style: TextStyle(
                                      fontSize: 10.0, color: Colors.grey[800]),
                                )))
                        : Container()
                  ])),
        ),
        Block(
            margin: EdgeInsets.only(top: 16.0),
            title: AppLocalizations.of(context).creatoDa,
            child: new NotificationListener<EntityNotification>(
                onNotification: _onNotify,
                child: UserListItem(widget.contest?.user, widget.onTapUser))),
      ].where((Widget e) => e != null).toList(),
    ));
  }
}
