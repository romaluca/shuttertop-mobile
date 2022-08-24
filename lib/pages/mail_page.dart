import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shuttertop/misc/app_localizations.dart';

class MailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
            Icon(Icons.alternate_email, size: 120.0, color: Colors.grey[400]),
            Container(
                margin: EdgeInsets.only(top: 32.0),
                child: Text(
                  "Ti abbiamo inviato una mail di confema",
                  style:
                      TextStyle(color: Colors.grey[600], fontFamily: "Raleway"),
                )),
            Text(
              AppLocalizations.of(context).controllaLaTuaCasellaDiPosta,
              style: TextStyle(color: Colors.grey[600], fontFamily: "Raleway"),
            )
          ])),
    ));
  }
}
