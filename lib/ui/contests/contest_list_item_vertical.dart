import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/contests/contest_thumb.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/ui/contests/contest_details_text.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class ContestListItemVertical extends StatefulWidget {
  ContestListItemVertical(this.contest, this.onTap)
      : super(key: new ObjectKey(contest));

  final Contest contest;
  final ShowContestPage onTap;
  @override
  ContestListItemVerticalState createState() =>
      new ContestListItemVerticalState();
}

class ContestListItemVerticalState extends State<ContestListItemVertical> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  double durationPercent;

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
    return Material(
        color: Colors.white,
        child: new InkWell(
            onTap: () => widget.onTap(widget.contest, join: false),
            child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ContestThumb(
                      widget.contest,
                      ContestThumbType.horizontal,
                      margin: EdgeInsets.only(bottom: 6.0),
                    ),
                    Text(widget.contest.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: "Raleway",
                            fontSize: 15.0,
                            color: Colors.grey[800])),
                    ContestDetailsText(
                      widget.contest,
                      fontColor: Colors.grey[500],
                      fontSize: 14.0,
                      short: true,
                      fontWeight: FontWeight.w400,
                      margin: EdgeInsets.only(top: 3.0),
                    ),
                  ]),
            )));
  }
}
