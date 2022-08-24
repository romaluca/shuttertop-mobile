import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/contests/contest_grid.dart';
import 'package:shuttertop/ui/contests/contest_loading_grid.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

class ContestListHome extends StatefulWidget {
  ContestListHome({@required this.onTap, @required this.scrollController});

  final ShowContestPage onTap;
  final ScrollController scrollController;

  @override
  _ContestListHomeState createState() => new _ContestListHomeState();
}

class ContestGroup {
  ContestGroup(this.title, this.fetch, this.onTapAll);
  final String title;
  final Function onTapAll;
  final Future<RequestListPage<Contest>> fetch;
}

class _ContestListHomeState extends State<ContestListHome> {
  List<ContestGroup> groups;

  Category category;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getGroups();
  }

  void _getGroups() {
    groups = <ContestGroup>[
      ContestGroup(
          "Recenti",
          shuttertop.contestRepository
              .fetch(pageSize: 4, category: category, order: ListOrder.news),
          () => WidgetUtils.showContestsNewsPage(context)),
      ContestGroup(
          "I migliori",
          shuttertop.contestRepository
              .fetch(pageSize: 4, category: category, order: ListOrder.top),
          () => WidgetUtils.showContestsTopPage(context)),
      ContestGroup(
          "Terminati",
          shuttertop.contestRepository.fetch(
              pageSize: 4,
              category: category,
              inProgress: false,
              order: ListOrder.news),
          () => WidgetUtils.showContestsFinishedPage(context))
    ];
  }

  void _onCategoryTap(Category c) async {
    if (category == c)
      category = null;
    else
      category = c;
    _getGroups();
    setState(() {
      isLoading = true;
    });
    new Timer(const Duration(milliseconds: 200), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  List<Widget> _getCategories() {
    return Contest.categories
        .map<Widget>((Category s) {
          return InkWell(
              onTap: () => _onCategoryTap(s),
              child: new Container(
                  margin: EdgeInsets.only(
                      left: s == Contest.categories[1] ? 16.0 : 0, right: 8),
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: PhysicalModel(
                      shadowColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                      elevation: 1,
                      color: Colors.transparent,
                      child: Container(
                          width: 130.0,
                          decoration: BoxDecoration(
                            gradient: s == category
                                ? WidgetUtils.categoryGradient(category)
                                : null,
                            color: s == category ? null : Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  width: 40,
                                  child: Icon(
                                    s.icon,
                                    size: 24,
                                    color: s == category
                                        ? Colors.white
                                        : Colors.grey[700],
                                  )),
                              Text(
                                s.name.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w300,
                                  color: s == category
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              )
                            ],
                          )))));
        })
        .toList()
        .sublist(1);
  }

  Widget _getCategoryList() {
    return Container(
        constraints: BoxConstraints(maxHeight: 130.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
              Colors.white,
              Colors.grey[50],
              Colors.grey[50],
              Colors.grey[50],
              Colors.grey[100]
            ])),
        child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: _getCategories()));
  }

  Widget _getContestGrid(int index) {
    if (isLoading) return ContestLoadingGrid(widget.scrollController);
    return new FutureBuilder<RequestListPage<Contest>>(
        future: groups[index].fetch,
        builder: (BuildContext context,
            AsyncSnapshot<RequestListPage<Contest>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              if (snapshot.data.totalEntries > 0)
                return Block(
                    title: groups[index].title,
                    buttonMargin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    onTapAll: snapshot.data.totalEntries > 4
                        ? groups[index].onTapAll
                        : null,
                    child: ContestGrid(snapshot.data.entries, widget.onTap,
                        scrollController: widget.scrollController));
              else
                return Container();
            }
          }
          return ContestLoadingGrid(widget.scrollController);
        });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = <Widget>[];
    list.add(_getCategoryList());
    for (int i = 0; i < groups.length; i++) list.add(_getContestGrid(i));
    return ListView(
      children: list,
      //controller: widget.scrollController,
    );
    return ListView(
      shrinkWrap: true,
      controller: widget.scrollController,
      children: list,
    );
  }
}
