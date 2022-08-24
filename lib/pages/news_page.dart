import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meta/meta.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/pages/contest_create_page.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/widget/tv_screen.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/activities/activity_list_item.dart';
import 'package:shuttertop/ui/users/user_stats.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';

class NewsPage extends StatefulWidget {
  final Function openDrawer;
  final Function openContests;
  final GlobalKey keyWins;
  final GlobalKey keyScore;
  final GlobalKey keyInProgress;

  const NewsPage(
      {Key key,
      @required this.openDrawer,
      @required this.openContests,
      this.keyWins,
      this.keyInProgress,
      this.keyScore})
      : super(key: key);

  static const String routeName = '/news';

  @override
  NewsPageState createState() => new NewsPageState();
}

class NewsPageState extends State<NewsPage> {
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  bool _scrolled;
  List<Activity> elements;
  bool _notBooked = false;
  int refreshCounter = 0;
  double top = 0;

  @override
  void initState() {
    super.initState();
    try {
      _scrolled = false;
      elements = <Activity>[];
      _scrollController = new ScrollController();
      _scrollController.addListener(() {
        setState(() {
          top = _scrollController.offset;
          if (_scrolled != _scrollController.offset > 0) _scrolled = !_scrolled;
        });
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<RequestListPage<Activity>> loadActivities(int page) async {
    print("loadActivities page: $page");
    return shuttertop.activityRepository.fetch(
        page: page,
        notEmpty: false,
        type: _notBooked ? ActivityFetchType.notBooked : ActivityFetchType.all);
  }

  void _showNotBooked() async {
    refreshCounter++;
    _notBooked = !_notBooked;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;
    final Widget svg = new SvgPicture.asset(
      'assets/images/rays.svg',
      color: AppColors.brandPrimary,
    );
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            /*SliverAppBar(
            titleSpacing: 0.0,
            elevation: _scrolled ? 2.0 : 1.0,
            //forceElevated: true,
            pinned: false,
            leading: Container(
              width: 0,
              height: 0,
            ),
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            title: _buildHeader(),
          )*/
          ];
        },
        body: Stack(children: <Widget>[
          Material(
              color: Colors.white,
              child: Container(
                  margin: EdgeInsets.only(top: statusbarHeight),
                  height: 235,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36)),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.grey[50],
                            Colors.grey[200]
                          ])))),
          LoadingListView<Activity>(loadActivities,
              elements: elements,
              scrollController: _scrollController,
              widgetAdapter: adapt,
              refreshRequestCounter: refreshCounter,
              loadingWidget: adapt(null, -1),
              emptyWidget: _emptyWidget(),
              indexer: (Activity e) => e.id),
        ]));
  }

  void _showObjectPage(dynamic element) {
    WidgetUtils.showObjectPage(context, element);
    setState(() {});
  }

  void _showContestPage(Contest contest,
      {@required bool join, @required bool showComments}) {
    WidgetUtils.showContestPage(context, contest,
        join: join, showComments: showComments);
    setState(() {});
  }

  void _showUserPage(User user) {
    WidgetUtils.showUserPage(context, user);
    setState(() {});
  }

  void _showCommentsPage(EntityBase element, {@required bool edit}) {
    WidgetUtils.showCommentsPage(context, element, edit: edit);
    setState(() {});
  }

  Widget _emptyWidget() {
    return Column(children: <Widget>[
      _getSubHeader(),
      //_getButtonAdd(),
      Expanded(
          child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).benvenutoSuShuttertop,
              style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: "Raleway",
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold),
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Text(
                  AppLocalizations.of(context)
                      .questoEIlMigliorPostoPerSficcanasare,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500]),
                )),
            Material(
                elevation: 0.0,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                child: InkWell(
                    onTap: _showNotBooked,
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                                color: AppColors.brandPrimary, width: 2.0)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 8.0),
                        child: Text(
                          AppLocalizations.of(context).andiamo,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: AppColors.brandPrimary,
                              fontWeight: FontWeight.bold),
                        ))))
          ],
        ),
      ))
    ]);
  }

  Widget adapt(List<Activity> activity, int index) {
    if (index == -1)
      return ListView(padding: EdgeInsets.all(0), children: <Widget>[
        _getSubHeader(),
        _getButtonAdd(),
        _getLoadingElement()
      ]);
    if (index == 0)
      return Column(children: <Widget>[
        _getSubHeader(),
        _getButtonAdd(),
        ActivityListItem(
          activity[index],
          onTap: _showObjectPage,
          onTapAllComments: _showCommentsPage,
          onTapJoin: _showContestPage,
          onTapUser: _showUserPage,
        ),
      ]);

    return ActivityListItem(activity[index],
        onTap: _showObjectPage,
        onTapAllComments: _showCommentsPage,
        onTapUser: _showUserPage,
        onTapJoin: _showContestPage);
  }

  Widget _getLoadingElement() {
    Widget _item = Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: <Widget>[
                    Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(53.0))),
                        )),
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                margin: EdgeInsets.only(top: 0.0),
                                height: 16,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3.0))),
                              )),
                          Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                margin: EdgeInsets.only(top: 8.0),
                                height: 12,
                                width: 120,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3.0))),
                              ))
                        ])),
                  ],
                )),
            Shimmer.fromColors(
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
                child: Container(
                  margin: EdgeInsets.only(top: 16.0),
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))),
                )),
            Container(
              height: 400,
            )
          ],
        ));
    return _item;
  }

  String _getUserImage() {
    try {
      return shuttertop.currentSession.user.getImageUrl(ImageFormat.thumb);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  Future<Null> _showCreateContest() async {
    final Contest contest = await Navigator.of(context).push(
        new MaterialPageRoute<Contest>(
            settings: const RouteSettings(name: ContestCreatePage.routeName),
            builder: (BuildContext context) => ContestCreatePage()));
    if (contest != null) {
      //_isFilterChanging = true;
      setState(() {
        //_contestsAdded += 1;
      });
      print("contest creato: ${contest.name}");
      //_isFilterChanging = false;
      WidgetUtils.showContestPage(context, contest,
          join: false, showComments: false);
      //setState(() {});
    } else
      print("nessun contest creato");
  }

  Widget _getButtonAdd() {
    return Container(
        padding: EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
            color: Colors.grey[200].withOpacity(0.8),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36), topRight: Radius.circular(36))),
        child: Container(
            color: Colors.transparent,
            child: Container(
                padding: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36))),
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: _showCreateContest,
                        child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Row(children: <Widget>[
                              Container(
                                  width: 40.0,
                                  height: 40.0,
                                  margin: EdgeInsets.only(right: 16.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey[700], width: 1.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50.0))),
                                  child:
                                      Icon(Icons.add, color: Colors.grey[700])),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Crea un contest",
                                    style: TextStyle(
                                        fontFamily: "Raleway",
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                        fontSize: 15.0),
                                  ),
                                  Text(
                                    "Scombina la giornata al prossimo",
                                    style: TextStyle(color: Colors.grey[400]),
                                  )
                                ],
                              )
                            ])))))));
  }

  Widget _getSubHeader() {
    const Radius radius = const Radius.circular(8.0);
    return Container(
        height: 226,
        child: Stack(children: <Widget>[
          Positioned(
              left: 0,
              right: 0,
              top: top,
              child: Container(

                  //color: Colors.grey[300],
                  color: Colors.transparent,
                  padding: EdgeInsets.only(top: 32, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: RichText(
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                    text: "Shuttertop",
                                    style: TextStyle(
                                        fontFamily: "Raleway",
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700]),
                                  ),
                                ]),
                              )),
                          Container(
                              margin: EdgeInsets.only(top: 9, right: 16),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40)),
                              child: IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    color: Colors.grey[700],
                                  ),
                                  onPressed: widget.openDrawer)),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        height: 2,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFFDD2476),
                              const Color(0xFFFF512F),
                            ], // whitish to gray
                            tileMode: TileMode
                                .repeated, // repeats the gradient over the canvas
                          ),
                        ),
                      ),
                      new Container(
                          margin:
                              EdgeInsets.only(top: 32.0, left: 12, right: 12),
                          decoration: BoxDecoration(
                            //border: Border.all(color: Colors.grey[50], width: 1),
                            // color: Colors.grey[50],
                            /*gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFF512F),
                        const Color(0xFFDD2476)
                      ]),*/
                            borderRadius: BorderRadius.only(
                              topRight: radius,
                              topLeft: radius,
                              bottomLeft: radius,
                              bottomRight: radius,
                            ),
                          ),
                          child: UserStats(
                            shuttertop.currentSession?.user,
                            isHome: true,
                            keyScore: widget.keyScore,
                            keyInProgress: widget.keyInProgress,
                            keyWins: widget.keyWins,
                          )),
                    ],
                  )))
        ]));
  }

  Widget _buildHeader() {
    return Material(
        elevation: 0.0,
        color: Colors.white,
        child: Container(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                padding: EdgeInsets.only(
                  right: 22.0,
                ),
                child: Row(children: <Widget>[
                  Expanded(
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Shuttertop",
                            style: Styles.header,
                          ))),

                  /*
                  IconButton(
                    icon: Icon(Icons.language),
                    color:
                        _notBooked ? AppColors.brandPrimary : Colors.grey[500],
                    tooltip: AppLocalizations.of(context).newsDalMondo,
                    onPressed: _showNotBooked,
                  ),*/
                  InkWell(
                      onTap: () => WidgetUtils.showUserPage(
                          context, shuttertop.currentSession.user),
                      child: Avatar(
                        _getUserImage(),
                        backColor: Colors.white,
                        size: 28.0,
                        border: 0.0,
                      )),
                ]))));
  }
}
