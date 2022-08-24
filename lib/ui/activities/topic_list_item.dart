import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/topic.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/contests/contest_thumb.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class TopicListItem extends StatelessWidget {
  TopicListItem(this.topic, this.onTap) : super(key: new ObjectKey(topic));

  final Topic topic;
  final int userId = new ShuttertopApp().currentSession.user.id;
  final dynamic onTap;

  Widget _getImageThumb() {
    try {
      if (topic.userTo != null && topic.user != null)
        return Avatar(
            (shuttertop.currentUserId != topic.userTo.id
                    ? topic.userTo
                    : topic.user)
                .getImageUrl(ImageFormat.thumb),
            backColor: Colors.grey,
            size: 50.0);
      else if (topic.photo != null)
        return Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                    topic.photo.getImageUrl(ImageFormat.thumb_small))),
          ),
        );
      else if (topic.contest != null)
        return ContestThumb(topic.contest, ContestThumbType.smallsquare);
      else
        return Container();
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return Container();
    }
  }

  Widget _getIcon() {
    IconData d;
    if (topic.photo != null)
      d = Icons.crop_original;
    else if (topic.contest != null)
      d = Icons.filter;
    else
      return Container();

    return Container(
        padding: EdgeInsets.only(right: 5.0),
        child: Icon(
          d,
          color: Colors.grey[500],
          size: 16.0,
        ));
  }

  bool _isNoRead() {
    try {
      if (topic.lastComment == null) return false;
      if (topic.readAt == null) return true;
      return topic.lastComment.insertedAt.compareTo(topic.readAt) > 0;
    } catch (error) {
      print("_isNoRead $error");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //String imageUrl = activity.getImageUrl();
    final DateFormat formatter = new DateFormat(
        DateTime.now().difference(topic.lastComment.insertedAt).inDays < 1
            ? 'hh:mm'
            : 'dd/MM/yy');
    return InkWell(
        onTap: () => onTap(), // () => _showObjectPage(context),
        child: Container(
            padding: EdgeInsets.all(0.0),
            child: Container(
                color: Colors.white,
                child: Column(children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(16.0),
                      child: Row(children: <Widget>[
                        _getImageThumb(),
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.only(left: 16.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(
                                              right: 10.0, bottom: 5.0),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Expanded(
                                                    child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                minHeight: 0.0),
                                                        child: Text(
                                                            topic.getName(shuttertop
                                                                .currentUserId),
                                                            maxLines: 2,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Raleway",
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                        .grey[
                                                                    800])))),
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        top: 3.0, left: 12.0),
                                                    child: topic.lastComment ==
                                                            null
                                                        ? Container()
                                                        : Text(
                                                            formatter.format(
                                                                topic
                                                                    .lastComment
                                                                    .insertedAt),
                                                            maxLines: 1,
                                                            textAlign: TextAlign
                                                                .start,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: _isNoRead()
                                                                    ? AppColors
                                                                        .brandPrimary
                                                                    : Colors.grey[
                                                                        400]))),
                                              ])),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _getIcon(),
                                            topic.lastComment == null
                                                ? Container()
                                                : Expanded(
                                                    child: topic.userTo == null
                                                        ? RichText(
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            text: TextSpan(
                                                                children: <
                                                                    TextSpan>[
                                                                  TextSpan(
                                                                      text:
                                                                          "${topic.lastComment.user.name}: ",
                                                                      style: Styles
                                                                          .subtitle),
                                                                  TextSpan(
                                                                      text: topic
                                                                          .lastComment
                                                                          .body,
                                                                      style: Styles
                                                                          .subtitle)
                                                                ]),
                                                          )
                                                        : Text(
                                                            topic.lastComment
                                                                .body,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: Styles
                                                                .subtitle),
                                                  )
                                          ])
                                    ]))),
                      ]))
                ]))));
  }
}
