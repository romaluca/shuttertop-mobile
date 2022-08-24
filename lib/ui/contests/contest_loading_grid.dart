import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ContestLoadingGrid extends StatelessWidget {
  ContestLoadingGrid(this.scrollController);

  final ScrollController scrollController;

  Widget _getGridElement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
            )),
        Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              margin: EdgeInsets.only(top: 8.0),
              height: 16,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(3.0))),
            )),
        Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
                height: 16,
                margin: EdgeInsets.only(top: 2.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(3.0))))),
        Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
                height: 14,
                width: 100.0,
                margin: EdgeInsets.only(top: 2.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(3.0)))))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 32),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: Container(
                  height: 18.0,
                  width: 130.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))),
                  margin: EdgeInsets.only(left: 16.0, bottom: 16.0),
                ),
              ),
              GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                controller: scrollController,
                children: <Widget>[
                  _getGridElement(),
                  _getGridElement(),
                  _getGridElement(),
                  _getGridElement()
                ],
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 16.0,
              )
            ]));
  }
}
