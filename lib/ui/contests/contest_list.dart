import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/pages/contest_create_page.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/contests/contest_list_item_vertical.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:shuttertop/ui/widget/button_submit.dart';
import 'package:shuttertop/ui/widget/empty_list.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/contests/contest_list_item.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';

class ContestList extends StatefulWidget {
  ContestList(
      {this.category,
      this.inProgress,
      this.order = ListOrder.news,
      this.scrollDirection = Axis.vertical,
      this.user,
      this.limit,
      this.type = ContestFetchType.all,
      this.search = "",
      this.searchMode = false,
      this.contestsAdded = 0,
      @required this.onTap,
      this.onTapAll});

  final Category category;
  final bool inProgress;
  final ListOrder order;
  final int contestsAdded;
  final int limit;
  final User user;
  final String search;
  final ShowContestPage onTap;
  final Function onTapAll;
  final ContestFetchType type;
  final bool searchMode;
  final Axis scrollDirection;

  static const String routeName = '/contest_list';

  @override
  _ContestListState createState() => new _ContestListState();
}

class _ContestListState extends State<ContestList> {
  List<Contest> elements;
  bool isLoaded;

  @override
  void initState() {
    super.initState();
    isLoaded = false;
    elements = <Contest>[];
  }

  Future<RequestListPage<Contest>> loadContests(int page) async {
    return await shuttertop.contestRepository.fetch(
        category: widget.category,
        inProgress: widget.inProgress,
        order: widget.order,
        search: widget.search,
        limit: widget.limit,
        page: page,
        type: widget.type,
        userId: widget.user?.id);
  }

  Widget _getListView() {
    return LoadingListView<Contest>(loadContests,
        elements: elements,
        widgetAdapter: adapt,
        refreshRequestCounter: widget.contestsAdded,
        indexer: (Contest e) => e.id,
        scrollDirection: widget.scrollDirection,
        emptyWidget: widget.searchMode
            ? _buttonAdd()
            : EmptyList(Icons.filter,
                AppLocalizations.of(context).nessunContestTrovato));
  }

  bool _onNotify(LoadedNotification notification) {
    setState(() {
      isLoaded = true;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scrollDirection == Axis.horizontal) {
      NotificationListener<LoadedNotification> notificationListener =
          new NotificationListener<LoadedNotification>(
              onNotification: _onNotify, child: _getListView());
      if (!isLoaded) return notificationListener;
      if (elements.isNotEmpty)
        return Block(
            title: _getTitle(),
            height: 190.0,
            onTapAll: widget.onTapAll,
            margin: EdgeInsets.all(0),
            child: notificationListener);
      else
        return Container();
    } else
      return _getListView();
  }

  String _getTitle() {
    if (widget.inProgress == false) return "Terminati";
    if (widget.order == ListOrder.news) return "Recenti";
    if (widget.order == ListOrder.top) return "I migliori";
    return "Contest";
  }

  Widget adapt(List<Contest> contest, int index) {
    if (widget.scrollDirection == Axis.vertical) {
      if (index == contest.length - 1)
        return Column(
          children: <Widget>[
            new ContestListItem(contest[index], widget.onTap),
            widget.searchMode ? _buttonAdd() : Container()
          ],
        );
      return new ContestListItem(contest[index], widget.onTap);
    } else
      return new ContestListItemVertical(contest[index], widget.onTap);
  }

  Widget _buttonAdd() {
    return Material(
        child: InkWell(
            onTap: _showCreateContest,
            child: Container(
                margin: EdgeInsets.only(top: 50.0),
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(12.0),
                child: ButtonSubmit(
                  text: AppLocalizations.of(context).aggiungiUnContest,
                ))));
  }

  Future<Null> _showCreateContest() async {
    final Contest contest = await Navigator.of(context).push(
        new MaterialPageRoute<Contest>(
            settings: const RouteSettings(name: ContestCreatePage.routeName),
            builder: (BuildContext context) => ContestCreatePage()));
    if (contest != null) {
      widget.onTap(contest, join: false);
    } else
      print("nessun contest creato");
  }
}
