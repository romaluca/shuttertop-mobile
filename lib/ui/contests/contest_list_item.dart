import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/contests/contest_thumb.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/ui/contests/contest_details_text.dart';

class ContestListItem extends StatefulWidget {
  ContestListItem(this.contest, this.onTap)
      : super(key: new ObjectKey(contest));

  final Contest contest;
  final ShowContestPage onTap;
  @override
  ContestListItemState createState() => new ContestListItemState();
}

class ContestListItemState extends State<ContestListItem> {
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
        child: new InkWell(
            highlightColor: Colors.black12,
            onTap: () => widget.onTap(widget.contest, join: false),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                color: Colors.white,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          bottom:
                              BorderSide(color: Colors.grey[200], width: 1.0)),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      height: 56.0,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            (widget.contest.categoryId ?? 0) > 0
                                                ? Text(
                                                    widget.contest.category.name
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontFamily: "Raleway",
                                                        fontSize: 10.0,
                                                        color: widget.contest
                                                            .category.colors[1],
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                : Container(),
                                            Text(widget.contest.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: "Raleway",
                                                    fontSize: 15.0,
                                                    color: Colors.grey[800])),
                                          ])),
                                  Container(
                                      child: ContestDetailsText(
                                    widget.contest,
                                    fontColor: Colors.grey[600],
                                    fontSize: 14.0,
                                    short: true,
                                    fontWeight: FontWeight.w400,
                                  )),
                                ]),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: ContestThumb(
                                widget.contest,
                                ContestThumbType.midsquare,
                              ))
                        ])))));
  }
}
