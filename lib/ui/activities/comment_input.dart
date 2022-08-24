import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/ui/users/avatar.dart';

class CommentInput extends StatelessWidget {
  CommentInput(this.element, this.onTap);

  final ShowCommentsPage onTap;
  final EntityBase element;

  String _getUserImageUrl() {
    try {
      return shuttertop.currentSession.user.getImageUrl(ImageFormat.thumb);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin:
            EdgeInsets.only(top: 12.0, bottom: 12.0, left: 11.0, right: 16.0),
        alignment: Alignment.bottomCenter,
        //color: Colors.white,
        height: 46.0,
        child: InkWell(
            onTap: () => onTap(element, edit: true),
            child: Container(
              child: Row(children: <Widget>[
                Expanded(
                  child: Material(
                      elevation: 0.0,
                      color: Colors.white,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                              border: Border.all(
                                  color: Colors.grey[300], width: 1.0),
                              color: Colors.grey[50]),
                          height: 46.0,
                          alignment: Alignment.centerLeft,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Avatar(
                                      _getUserImageUrl(),
                                      backColor: Colors.grey,
                                      size: 36.0,
                                    )),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .sputaIlRospo,
                                          style: TextStyle(
                                              color: Colors.grey[400],
                                              fontFamily: "Raleway",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.0),
                                        ))),
                                Container(
                                    padding: EdgeInsets.only(
                                        left: 12.0, right: 12.0),
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.grey[700],
                                      size: 26.0,
                                    ))
                              ]))),
                ),
              ]),
            )));
  }
}
