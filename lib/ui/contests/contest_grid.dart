import 'package:flutter/material.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/ui/contests/contest_list_item_vertical.dart';

class ContestGrid extends StatelessWidget {
  ContestGrid(this.elements, this.onTap, {this.scrollController});
  final List<Contest> elements;
  final Function onTap;
  final ScrollController scrollController;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 200.0;
    final double itemWidth = size.width / 2;
    return Container(
        padding: EdgeInsets.all(0),
        constraints: BoxConstraints(maxHeight: 390.0),
        child: GridView.count(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          shrinkWrap: true,
          // physics: ClampingScrollPhysics(),
          controller: scrollController,
          physics: scrollController != null
              ? null
              : const NeverScrollableScrollPhysics(),
          //controller: new ScrollController(keepScrollOffset: false),
          childAspectRatio: (itemWidth / itemHeight),
          children: elements
              .map((Contest contest) => ContestListItemVertical(contest, onTap))
              .toList(),
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 16.0,
        ));
  }
}
