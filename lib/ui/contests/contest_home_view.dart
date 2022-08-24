import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/ui/contests/contest_details_text.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/widget/tag.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/ui/activities/comment_block.dart';
import 'package:shuttertop/ui/photos/photo_leaders_item.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:shuttertop/ui/photos/photos_row.dart';
import 'package:shuttertop/ui/users/users_row.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class ContestHomeView extends StatefulWidget {
  const ContestHomeView(
      {Key key,
      @required this.contest,
      @required this.onTapInfo,
      @required this.onTapLeaders,
      @required this.onTapPhotos,
      @required this.onTapPhoto,
      @required this.onTapPhotoLeaders,
      @required this.onTapFollowers,
      @required this.onTapAllComments,
      @required this.onTapUser})
      : super(key: key);

  final Contest contest;
  final Function onTapInfo;
  final Function onTapLeaders;
  final Function onTapPhotos;
  final Function onTapFollowers;
  final ShowPhotoPage onTapPhoto;
  final Function onTapPhotoLeaders;
  final ShowCommentsPage onTapAllComments;
  final ShowUserPage onTapUser;

  @override
  ContestHomeViewState createState() => new ContestHomeViewState();
}

class ContestHomeViewState extends State<ContestHomeView> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  double durationPercent;

  Widget _getLeadersItem(Photo photo) {
    return PhotoLeadersItem(photo, widget.onTapPhotoLeaders,
        margin: photo.position > 1 ? EdgeInsets.only(top: 8.0) : null,
        isWinner: widget.contest.winnerId == photo.id);
  }

  @override
  void initState() {
    durationPercent = DateTime.now().compareTo(widget.contest.expiryAt) > 0
        ? 0.0
        : (widget.contest.expiryAt.difference(DateTime.now()).inMinutes *
            100 /
            widget.contest.expiryAt
                .difference(widget.contest.startAt)
                .inMinutes);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: 0.0),
      children: <Widget>[
        _buildInfo(),
        _buildLeaders(),
        widget.contest.photosCount > 3
            ? PhotosRow(
                widget.contest.photos,
                widget.contest.photosCount,
                widget.onTapPhotos,
                AppLocalizations.of(context).fotoRecenti,
                onElementTap: widget.onTapPhoto,
              )
            : Container(),
        UsersRow(widget.contest.followers, widget.contest.followersCount,
            AppLocalizations.of(context).followers, widget.onTapFollowers),
        CommentBlock(widget.contest, widget.onTapAllComments, widget.onTapUser),
      ].where((Widget e) => e != null).toList(),
    );
  }

  Widget _getTimerGraph() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          child: AnimatedCircularChart(
            key: _chartKey,
            size: const Size(200.0, 200.0),
            initialChartData: <CircularStackEntry>[
              new CircularStackEntry(
                <CircularSegmentEntry>[
                  new CircularSegmentEntry(
                    100 - durationPercent,
                    Colors.blueGrey[800],
                    rankKey: 'percentage',
                  ),
                  new CircularSegmentEntry(
                    durationPercent,
                    Colors.grey[300],
                    rankKey: 'percentage1',
                  )
                ],
                rankKey: 'percentage',
              ),
            ],
            chartType: CircularChartType.Radial,
            edgeStyle: SegmentEdgeStyle.round,
            percentageValues: true,
          ),
        ),
        Container(
            alignment: Alignment.center,
            child: Tag(
                label: widget.contest.isExpired
                    ? (widget.contest.winnerId != null
                        ? AppLocalizations.of(context).unVincitore.toLowerCase()
                        : AppLocalizations.of(context)
                            .zeroVincitori
                            .toLowerCase())
                    : AppLocalizations.of(context).alTermine.toLowerCase(),
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(minWidth: 90.0),
                  child: ContestDetailsText(
                    widget.contest,
                    fontColor: Colors.grey[700],
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300,
                    onlyTime: true,
                  ),
                ))),
      ],
    );
  }

  Widget _getWinner() {
    const Color color = Color(0xFFffbf00);

    final Color color2 = Colors.brown[700].withOpacity(0.5);
    final Color color3 = Colors.brown[700].withOpacity(0.3);
    final Widget svg = new SvgPicture.asset(
      'assets/images/award.svg',
      color: color2,
    );
    final User user = widget.contest.leaders.first.user;
    final Photo photo = widget.contest.leaders.first;
    return InkWell(
        onTap: () => WidgetUtils.showUserPage(context, user),
        child: Container(
            height: 200.0,
            width: 162.0,
            margin: EdgeInsets.only(top: 24.0),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
                //border: Border.all(color: color3, width: 0.5),
                //color: color,
                gradient: AppColors.gradientsWinner[0],
                borderRadius: BorderRadius.circular(10)),
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Positioned(
                    top: 16.0,
                    child: Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          "WINNER",
                          style: TextStyle(color: color2),
                        ))),
                Positioned(
                    child: Container(
                        margin: EdgeInsets.only(top: 28.0, bottom: 30.0),
                        width: 120.0,
                        height: 120.0,
                        child: svg)),
                Positioned(
                    top: 43.0,
                    child: Container(
                        margin: EdgeInsets.only(top: 8.0),
                        child: Avatar(
                          user.getImageUrl(ImageFormat.thumb_small),
                          size: 60.0,
                          border: 1,
                          shadow: 0,
                          backColor: Colors.white,
                        ))),
                Positioned(
                    bottom: 16.0,
                    child: Container(
                        child: Column(children: <Widget>[
                      Text(
                        user.name,
                        style: TextStyle(
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.bold,
                            color: color2),
                      ),
                      Text(
                        "${photo.votesCount} top",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Raleway",
                            color: Colors.white),
                      )
                    ]))),
              ],
            )));
  }

  Widget _buildInfo() {
    return Column(children: <Widget>[
      Block(
        margin: EdgeInsets.only(top: 1.0),
        child: Container(
            color: Colors.white,
            //margin: EdgeInsets.only(top: 16.0),
            padding: EdgeInsets.only(top: 16.0),
            child: widget.contest.isExpired && widget.contest.photosCount > 0
                ? _getWinner()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _getTimerGraph(),
                      Container(
                          height: 200.0,
                          alignment: AlignmentDirectional.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                  onTap: widget.onTapPhotos,
                                  child: Tag(
                                      label: AppLocalizations.of(context)
                                          .foto
                                          .toLowerCase(),
                                      value: widget.contest.photosCount
                                          .toString())),
                              InkWell(
                                  onTap: widget.onTapFollowers,
                                  child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      child: Tag(
                                          label: AppLocalizations.of(context)
                                              .followers
                                              .toLowerCase(),
                                          value: widget.contest.followersCount
                                              .toString()))),
                              InkWell(
                                  onTap: () => widget.onTapAllComments(
                                      widget.contest,
                                      edit: false),
                                  child: Tag(
                                      label: AppLocalizations.of(context)
                                          .commenti
                                          .toLowerCase(),
                                      value: widget.contest.commentsCount
                                          .toString())),
                            ],
                          ))
                    ],
                  )),
      ),
      /*(widget.contest.winnerId != null && widget.contest.leaders != null
              && widget.contest.leaders.isNotEmpty)
            ? PhotoWinner(widget.contest.leaders.first, widget.onTapPhotoLeaders, widget.onTapUser)
            : Container(),*/
      ((widget.contest.description ?? "").isEmpty)
          ? Container(
              width: 0.0,
              height: 0.0,
            )
          : Block(
              title: AppLocalizations.of(context).info,
              child: InkWell(
                  onTap: widget.onTapInfo,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.contest.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          fontFamily: "Raleway"),
                    ),
                    alignment: Alignment.topLeft,
                  )))
    ]);
  }

  int _getLeadersMaxLength() {
    try {
      return widget.contest.leaders.length > 3
          ? 3
          : widget.contest.leaders.length;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return 0;
    }
  }

  Widget _buildLeaders() {
    if (widget.contest.leaders == null || widget.contest.leaders.isEmpty)
      return Container(
        width: 0.0,
        height: 0.0,
      );
    final List<Widget> list = <Widget>[];
    list.addAll(widget.contest.leaders
        .sublist(0, _getLeadersMaxLength())
        .map((Photo photo) => _getLeadersItem(photo))
        .toList());
    return Block(
        title: AppLocalizations.of(context).classifica,
        onTapAll: ((widget.contest.photosCount ?? 0) > 3)
            ? widget.onTapLeaders
            : null,
        titleViewAll: AppLocalizations.of(context).visualizzaTutti,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: list)));
  }
}
