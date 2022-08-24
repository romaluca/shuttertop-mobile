import 'dart:async';

import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/topic.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/activities/topic_list_item.dart';
import 'package:shuttertop/ui/widget/empty_list.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/activities/notify_list_item.dart';
import 'package:flutter/material.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';

class NotifiesPage extends StatefulWidget {
  const NotifiesPage(this.user,
      {this.type = ActivityFetchType.notifies, Key key, this.openDrawer})
      : super(key: key);

  final Function openDrawer;

  final ActivityFetchType type;
  final User user;

  static const String routeName = '/notifies';

  @override
  _NotifiesPageState createState() => new _NotifiesPageState();
}

class _NotifiesPageState extends State<NotifiesPage>
    with SingleTickerProviderStateMixin {
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Activity> elements;
  List<Topic> topics;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      try {
        if (mounted &&
            _tabController.index == 1 &&
            shuttertop.currentSession.notifyCount > 0)
          setState(() => shuttertop.currentSession.notifyCount = 0);
      } catch (error) {
        print(error);
      }
    });
    elements = <Activity>[];
    topics = <Topic>[];
  }

  Future<RequestListPage<Activity>> loadNotifies(int page) async {
    return await shuttertop.activityRepository
        .fetch(page: page, type: widget.type, element: widget.user);
  }

  Future<RequestListPage<Topic>> loadTopics(int page) async {
    if (page == 1) {
      shuttertop.currentSession.notifyMessageCount = 0;
    }
    return await shuttertop.topicRepository.fetch(page: page);
  }

  void _showActivityObjectPage(Activity activity) {
    WidgetUtils.showActivityObjectPage(context, activity);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      body: widget.type == ActivityFetchType.score
          ? Container(
              color: Colors.white,
              child: LoadingListView<Activity>(loadNotifies,
                  emptyWidget: _getEmptyNotifies(),
                  elements: elements,
                  widgetAdapter: _adapt,
                  indexer: (Activity e) => e.id))
          : TabBarView(
              controller: _tabController,
              children: <Widget>[
                LoadingListView<Topic>(loadTopics,
                    emptyWidget: _getEmptyTopics(),
                    elements: topics,
                    widgetAdapter: _adaptTopic,
                    indexer: (Topic e) => e.lastComment.insertedAt.millisecond),
                LoadingListView<Activity>(loadNotifies,
                    emptyWidget: _getEmptyNotifies(),
                    elements: elements,
                    widgetAdapter: _adapt,
                    indexer: (Activity e) => e.id)
              ],
            ),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: widget.type == ActivityFetchType.score
                ? SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 6.0, bottom: 5.0),
                            child: Text(widget.user.name,
                                style: TextStyle(
                                  color: Colors.black,
                                ))),
                        Text(
                          AppLocalizations.of(context).cronologiaPunti,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        )
                      ]))
                : Text(
                    AppLocalizations.of(context).posta,
                    style: Styles.header,
                  ),
            pinned: true,
            leading: widget.openDrawer == null
                ? IconButton(
                    icon: new Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop())
                : Container(),
            elevation: 1.0,
            snap: false,
            floating: false,
            bottom: widget.type == ActivityFetchType.score
                ? null
                : TabBar(
                    labelStyle:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700),
                    indicatorWeight: 2.0,
                    labelColor: Colors.grey[700],
                    unselectedLabelColor: Colors.grey[400],
                    indicatorColor: Colors.grey[500],
                    controller: _tabController,
                    tabs: <Tab>[
                      Tab(text: AppLocalizations.of(context).messaggi),
                      shuttertop.currentSession.notifyCount == 0
                          ? Tab(text: AppLocalizations.of(context).notifiche)
                          : Tab(
                              child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(AppLocalizations.of(context).notifiche,
                                    softWrap: false,
                                    overflow: TextOverflow.fade),
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.brandPrimary,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0))),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 3.0),
                                  margin: EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    shuttertop.currentSession.notifyCount
                                        .toString(),
                                    style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                )
                              ],
                            )
                              //text: "Notifiche"
                              )
                    ].toList()),
          )
        ];
      },
    );
  }

  Widget _getEmptyNotifies() {
    if (widget.type == ActivityFetchType.score)
      return EmptyList(Icons.whatshot,
          AppLocalizations.of(context).nonCiSonoPuntiTotalizzati);
    else
      return EmptyList(
          Icons.notifications, AppLocalizations.of(context).nonCiSonoNotifiche);
  }

  Widget _adapt(List<Activity> activity, int index) {
    return NotifyListItem(activity[index], _showActivityObjectPage);
  }

  Widget _getEmptyTopics() {
    return EmptyList(
        Icons.comment, AppLocalizations.of(context).seiSulTaciturno);
  }

  Widget _adaptTopic(List<Topic> topic, int index) {
    return TopicListItem(topic[index], () async {
      await WidgetUtils.showCommentsPage(
          context, topic[index].getObject(shuttertop.currentUserId),
          edit: false, topic: topic[index]);
      setState(() {
        topic.sort((Topic a, Topic b) =>
            b.lastComment.insertedAt.compareTo(a.lastComment.insertedAt));
      });
    });
  }
}
