import 'package:flutter/material.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:translator/translator.dart';

class CommentListItem extends StatefulWidget {
  CommentListItem(this.comment, this.onTap)
      : super(key: new ObjectKey(comment));

  final Comment comment;
  final ShowUserPage onTap;

  @override
  _CommentListItemState createState() => new _CommentListItemState();
}

class _CommentListItemState extends State<CommentListItem> {
  bool translated = false;
  String translate = "";

  String _getUserImageUrl() {
    try {
      return widget.comment.user.getImageUrl(ImageFormat.thumb);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  String _getUserName() {
    try {
      return widget.comment.user.name;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  void _onTapTranslate() async {
    final GoogleTranslator translator = GoogleTranslator();
    if (!translated) {
      translate = await translator.translate(widget.comment?.body,
          to: shuttertop.currentSession.user?.language);
    }
    setState(() {
      translated = !translated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => widget.onTap(widget.comment?.user),
        child: Container(
            child: Container(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          width: 68.0,
                          height: 36.0,
                          alignment: Alignment.center,
                          child: Avatar(
                            _getUserImageUrl(),
                            backColor: Colors.grey,
                            size: 36.0,
                          )),
                      Expanded(
                        child: Container(
                            margin: EdgeInsets.only(
                                left: 10.0, bottom: 12.0, right: 16.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(bottom: 2.0),
                                      child: Text(_getUserName(),
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: "Raleway",
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600]))),
                                  RichText(
                                      text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[800],
                                        fontFamily: ""),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: translated
                                            ? translate
                                            : widget.comment?.body,
                                      ),
                                    ],
                                  )),
                                  Row(children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(top: 5.0),
                                        child: Text(
                                            timeago.format(
                                                widget.comment?.insertedAt),
                                            style: TextStyle(
                                                color: Colors.grey[400]))),
                                    widget.comment.user.language !=
                                            shuttertop
                                                .currentSession.user.language
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                top: 5.0, left: 16.0),
                                            child: InkWell(
                                                onTap: _onTapTranslate,
                                                child: Text(
                                                  translated
                                                      ? "Nascondi traduzione"
                                                      : "Visualizza traduzione",
                                                  style: TextStyle(
                                                      fontSize: 10.0,
                                                      color: Colors.grey[800]),
                                                )))
                                        : Container()
                                  ])
                                ])),
                      ),
                    ]))));
  }
}
