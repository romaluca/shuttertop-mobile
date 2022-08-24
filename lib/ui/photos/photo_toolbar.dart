import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/ui/widget/circle_icon_button.dart';
import 'package:shuttertop/ui/widget/rainbow_gradient.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class PhotoToolbar extends StatelessWidget {
  const PhotoToolbar(
    this.photo, {
    Key key,
    this.shadowRadius = 0.0,
    @required this.vote,
  }) : super(key: key);

  final Photo photo;
  final Function vote;
  final double shadowRadius;

  Widget _buildIconTop([bool fullScreen = false]) {
    return CircleIconButton(
      photo != null && photo.voted
          ? FontAwesomeIcons.solidHeart
          : FontAwesomeIcons.heart,
      () => vote(),
      color: (photo != null && photo.voted
          ? Colors.redAccent
          : (fullScreen ? Colors.white : Colors.grey[700])),
      margin: EdgeInsets.only(right: 6.0),
    );
  }

  bool _isContestExpired() {
    try {
      return photo.contest.isExpired;
    } catch (error) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        //padding: new EdgeInsets.only(right: 8.0),
        child: Column(children: <Widget>[
          Container(
            width: 20.0,
            height: 3.0,
            margin: EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey.withOpacity(0.4)),
          ),
          Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _buildIconTop(),
                    Container(
                        margin: EdgeInsets.only(right: 5.0),
                        constraints: BoxConstraints(minWidth: 22.0),
                        child: Text(
                          photo.votesCount.toString(),
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700]),
                        )),
                  ]),
              Row(children: <Widget>[
                CircleIconButton(
                    FontAwesomeIcons.comment,
                    () => WidgetUtils.showCommentsPage(context, photo,
                        edit: true),
                    color: Colors.grey[700],
                    margin: EdgeInsets.only(right: 6.0)),
                Container(
                    margin: EdgeInsets.only(right: 5.0),
                    constraints: BoxConstraints(minWidth: 22.0),
                    child: Text(
                      photo.commentsCount.toString(),
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500),
                    )),
              ]),
              Container(
                  child: CircleIconButton(
                FontAwesomeIcons.shareSquare,
                () => WidgetUtils.share(photo),
                color: Colors.grey[700],
              )),
              Expanded(
                  child: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 0.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(right: 5.0),
                          constraints: BoxConstraints(minWidth: 22.0),
                          child: Text(
                            "${photo.position}°",
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800]),
                          )),
                      CircleIconButton(
                          photo.isWinner
                              ? FontAwesomeIcons.handPeace
                              : Icons.equalizer,
                          () => WidgetUtils.showCommentsPage(context, photo,
                              edit: true),
                          background: AppColors.background,
                          color: Colors.grey[800],
                          margin: EdgeInsets.only(right: 0.0)),
                    ]),
              ))
            ],
          )
        ]));
  }
}
