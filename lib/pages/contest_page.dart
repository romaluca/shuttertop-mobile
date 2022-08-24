import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/users/followers_view.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/pages/contest_create_page.dart';
import 'package:shuttertop/ui/contests/contest_details_view.dart';
import 'package:shuttertop/ui/contests/contest_header.dart';
import 'package:shuttertop/ui/contests/contest_home_view.dart';
import 'package:shuttertop/ui/activities/notify_list_item.dart';
import 'package:shuttertop/ui/photos/photo_list_item.dart';
import 'package:shuttertop/ui/photos/photo_leaders_item.dart';
import 'package:shuttertop/pages/photo_slide_page.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';

enum ContestPageMenu { edit, cover, delete }

class ContestPage extends StatefulWidget {
  const ContestPage(this.contest,
      {Key key, @required this.join, this.initLoad = true})
      : super(key: key);

  final Contest contest;
  final bool join;
  final bool initLoad;

  static const String routeName = '/contest';

  @override
  _ContestPageState createState() => new _ContestPageState();
}

class _ContestPageState extends State<ContestPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController;
  TabController _tabController;

  bool _isLoading = true;
  bool _isScrolled = false;

  bool _isRewarded = false;

  final double _appBarHeight = 316.0;

  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addObserver(this);
      _connect();
      if (widget.initLoad)
        _loadContest();
      else if (mounted) setState(() => _isLoading = false);
      _scrollController = new ScrollController();
      _tabController = new TabController(vsync: this, length: 5);
      _tabController.addListener(() {
        _scrollController.animateTo(
          _appBarHeight - 52.0,
          curve: const Interval(0.5, 1.0, curve: Curves.ease),
          duration: const Duration(milliseconds: 250),
        );
      });
      if (widget.join)
        WidgetUtils.getImage(
            context, AppLocalizations.of(context).scendiInCampo, _onPhotoReady);
      RewardedVideoAd.instance.listener =
          (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
        if (event == RewardedVideoAdEvent.rewarded) {
          print("oleeee");
        }
      };
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  Future<Null> _connect() async {
    /*_leaveContest = await shuttertop.contestRepository.join(widget.contest,
        onVoted: (ResponseStatus status, [dynamic result]) {});
    _leaveUser =
        await shuttertop.userRepository.join(shuttertop.currentSession.user);*/
  }

  Future<Null> _leave([bool force = false]) async {
    /*if (_leaveContest || force)
      shuttertop.contestRepository.leave(widget.contest);
    if (_leaveUser || force)
      shuttertop.userRepository.leave(shuttertop.currentSession.user);*/
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _leave(false);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused)
      shuttertop.disconnect(true);
    else if (state == AppLifecycleState.resumed) _connect();
  }

  Future<Photo> _addPhoto(File imageFile) async {
    print("------addPhoto contestId ${widget.contest.id}");
    final Photo p = await shuttertop.photoRepository
        .create(imageFile, widget.contest.id, shuttertop.getS3);
    print("_____added Photo: $p");
    if (p != null) {
      widget.contest.photosUser.add(p);
      if ((p.position ?? 0) < 4) widget.contest.leaders.add(p);
    }
    return p;
  }

  Future<Null> _loadContest() async {
    await shuttertop.contestRepository
        .get(widget.contest.slug, contest: widget.contest);
    _isLoading = false;
    if (mounted) setState(() {});
  }

  Future<bool> _addCover(File imageFile) async {
    return await shuttertop.contestRepository
        .addCover(imageFile, widget.contest, shuttertop.getS3);
  }

  Future<RequestListPage<Photo>> _loadPhotos(int page) async {
    final RequestListPage<Photo> list =
        await shuttertop.photoRepository.fetch(widget.contest, page: page);
    return list;
  }

  Future<RequestListPage<Photo>> _loadLeaders(int page) async {
    final RequestListPage<Photo> list = await shuttertop.photoRepository
        .fetchLeaders(widget.contest, page: page);
    return list;
  }

  void _afterAd(File fileName) async {
    final Photo photo = await _addPhoto(fileName);
    print("_onPhotoReady photo: $photo");
    if (photo != null && mounted) {
      setState(() {
        widget.contest.photos.add(photo);
        widget.contest.photosCount++;
      });
      Navigator.of(context).pop();
      await WidgetUtils.showPhotoPage(context, photo,
          showComments: false, parentElement: widget.contest);
      print("PHOTO AFER READI COUNTS: ${widget.contest.photosCount}");
      setState(() {});
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<Null> _onPhotoReady(File fileName, [Exception error]) async {
    _isRewarded = false;
    if (fileName != null) {
      print("_onPhotoReady $fileName");
      final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
        keywords: <String>['shuttertop', 'contest fotografici'],
        contentUrl: 'https://shuttertop.com',
        childDirected: false,
        designedForFamilies: false,
        gender: MobileAdGender
            .unknown, // or MobileAdGender.female, MobileAdGender.unknown
        testDevices: <
            String>[], // Android emulators are considered test devices
      );

      RewardedVideoAd.instance.load(
          adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: targetingInfo);

      RewardedVideoAd.instance.listener =
          (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
        print("----------- RewardedVideoAd event $event");
        if (event == RewardedVideoAdEvent.loaded) {
          RewardedVideoAd.instance.show();
        } else if (event == RewardedVideoAdEvent.rewarded ||
            event == RewardedVideoAdEvent.failedToLoad) {
          _isRewarded = true;
          _afterAd(fileName);
        } else if (event == RewardedVideoAdEvent.closed && !_isRewarded) {
          Navigator.of(context).pop();
        }
      };

      return;
    } else if (error != null) {
      print("ERRORE - ContestPage _onPhotoReady: $error");
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("$error")));
    }
  }

  Future<Null> _onCoverReady(File fileName, [dynamic error]) async {
    bool ret = false;
    if (fileName != null) {
      ret = (await _addCover(fileName));
      print("----------getImage cover end");
    }
    Navigator.of(context).pop();
    if (ret && mounted) setState(() {});
  }

  void _deleteContest() async {
    final bool ret = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Conferma eliminazione"),
            content: new Text(
                "Sei sicuro di voler eliminare ${widget.contest.name}?"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("ANNULLA"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              new FlatButton(
                child: new Text("ELIMINA"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
    if (ret && await shuttertop.contestRepository.delete(widget.contest.id))
      Navigator.of(context).pop();
  }

  void _setNewCover() {
    WidgetUtils.getImage(
        context, AppLocalizations.of(context).inserisciLaCover, _onCoverReady);
  }

  void _handleMoreMenu(ContestPageMenu value) {
    switch (value) {
      case ContestPageMenu.cover:
        _setNewCover();
        break;
      case ContestPageMenu.edit:
        _showEditContest();
        break;
      case ContestPageMenu.delete:
        _deleteContest();
        break;
      default:
    }
  }

  Future<Null> _showRenewContest() async {
    final Contest contest = await Navigator.of(context).push(
        new MaterialPageRoute<Contest>(
            settings: const RouteSettings(name: ContestCreatePage.routeName),
            builder: (BuildContext context) =>
                new ContestCreatePage(widget.contest, true)));
    if (contest != null)
      await WidgetUtils.showContestPage(context, contest,
          join: false, showComments: false);
  }

  Future<Null> _showEditContest() async {
    final Contest contest = await Navigator.of(context).push(
        new MaterialPageRoute<Contest>(
            settings: const RouteSettings(name: ContestCreatePage.routeName),
            builder: (BuildContext context) =>
                new ContestCreatePage(widget.contest)));
    if (contest != null && mounted)
      setState(() {
        widget.contest.name = contest.name;
        widget.contest.categoryId = contest.categoryId;
        widget.contest.expiryAt = contest.expiryAt;
        widget.contest.description = contest.description;
      });
  }

  bool _isContestCurrentUser() {
    try {
      return shuttertop.currentSession.user == widget.contest.user;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  List<Widget> _getActions() {
    if (_isLoading) return null;
    return <Widget>[
      _isContestCurrentUser()
          ? PopupMenuButton<ContestPageMenu>(
              onSelected: (ContestPageMenu value) {
                _handleMoreMenu(value);
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuItem<ContestPageMenu>>[
                    PopupMenuItem<ContestPageMenu>(
                        value: ContestPageMenu.edit,
                        child: Text(
                            AppLocalizations.of(context).modificaIlContest)),
                    PopupMenuItem<ContestPageMenu>(
                        value: ContestPageMenu.cover,
                        child: Text(AppLocalizations.of(context)
                            .inserisciUnImmagineDiCopertiva)),
                    PopupMenuItem<ContestPageMenu>(
                        value: ContestPageMenu.delete,
                        child: Text(
                            AppLocalizations.of(context).eliminaIlContest)),
                  ],
            )
          : null,
    ].where((Widget e) => e != null).toList();
  }

  void _selectTab(int idx) {
    _tabController.animateTo(idx);
  }

  Widget adaptLeaders(List<Photo> photo, int index) {
    try {
      //if (widget.contest.winnerId != null && widget.contest.winnerId == photo[index].id)
      //  return PhotoWinner(photo[index], _showPhotoLeadersPage, _showUserPage);
      //else
      return PhotoLeadersItem(
        photo[index],
        _showPhotoLeadersPage,
        isWinner: widget.contest.winnerId == photo[index].id,
        margin: EdgeInsets.only(bottom: 8.0),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return Container();
    }
  }

  Future<Null> _showPhotoSlidePage(Photo photo) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: PhotoSlidePage.routeName),
            builder: (BuildContext context) => PhotoSlidePage(
                  widget.contest.photos,
                  element: widget.contest,
                  params: <String, String>{
                    "contest_id": widget.contest.id.toString()
                  },
                  index: widget.contest.photos.indexOf(photo),
                )));

    if (mounted) setState(() {});
  }

  Future<Null> _showUserPage(User user) async {
    print("_showUserPage: ${user.slug} ");
    await WidgetUtils.showUserPage(context, user);
    if (mounted) setState(() {});
  }

  Future<Null> _showActivityObjectPage(Activity activity) async {
    await WidgetUtils.showActivityObjectPage(context, activity);
    if (mounted) setState(() {});
  }

  Widget adaptPhotos(List<Photo> photo, int index) {
    return PhotoListItem(
      photo: photo[index],
      onTap: (Photo p) => _showPhotoSlidePage(p),
    );
  }

  Widget adaptActivities(Activity activity, int index) {
    return NotifyListItem(activity, _showActivityObjectPage);
  }

  void onError(String message) {
    print("ContestPage onError");
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Null> _showPhotoLeadersPage(Photo photo) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: PhotoSlidePage.routeName),
            builder: (BuildContext context) => PhotoSlidePage(
                    widget.contest.leaders,
                    element: widget.contest,
                    index: widget.contest.leaders.indexOf(photo),
                    params: <String, String>{
                      "contest_id": widget.contest.id.toString(),
                      "order": "top"
                    })));
  }

  Future<Null> _checkScrolling(double height) async {
    try {
      if (mounted && _isScrolled != (height < 200))
        setState(() {
          _isScrolled = (height < 200);
        });
    } catch (error) {
      // ignore
    }
  }

  bool _onNotify(EntityNotification notification) {
    if (mounted) setState(() {});
    return false;
  }

  Future<Null> _showCommentsPage(EntityBase element, {bool edit}) async {
    await WidgetUtils.showCommentsPage(context, element, edit: edit);
    if (mounted) setState(() {});
  }

  bool _showActionButton() {
    try {
      return _isScrolled &&
          widget.contest.photosUser == null &&
          !widget.contest.isExpired;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      floatingActionButton: _showActionButton()
          ? FloatingActionButton(
              elevation: 1.0,
              onPressed: () => WidgetUtils.getImage(context,
                  AppLocalizations.of(context).scendiInCampo, _onPhotoReady),
              child: Icon(Icons.camera_alt, color: Colors.white))
          : null,
      body: (widget.contest?.name == null)
          ? Center(child: WidgetUtils.spinLoader())
          : NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: _appBarHeight,
                    pinned: true,

                    iconTheme: IconThemeData(
                        color: _isScrolled ? Colors.black87 : Colors.white),
                    forceElevated: false,
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    elevation: 0.5, //_getAppBarIconColor() != Colors.white
                    //? 1.0 : 0.0,
                    title: _isScrolled
                        ? Text(widget.contest?.name ?? "", style: Styles.header)
                        : null,
                    floating: false,
                    snap: false,
                    actions: _getActions(),
                    flexibleSpace: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      _checkScrolling(constraints.biggest.height);
                      final double opacity = constraints.biggest.height > 78.0
                          ? 1.0 - ((constraints.biggest.height - 78.0) / 212.0)
                          : 1.0;
                      return NotificationListener<EntityNotification>(
                          onNotification: _onNotify,
                          child: ContestHeader(
                            contest: widget.contest,
                            onTapRenew: () => _showRenewContest(),
                            onTapNewCover: () => _setNewCover(),
                            onTapJoin: () => WidgetUtils.getImage(
                                context,
                                AppLocalizations.of(context).scendiInCampo,
                                _onPhotoReady,
                                "Guarda questo breve video mentre lavoriamo per te"),
                            opacity: (opacity ?? 0) < 0 ? 0.0 : opacity,
                            height: constraints.biggest.height,
                            isLoading: _isLoading,
                          ));
                    }),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(TabBar(
                      labelStyle: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w700),
                      labelColor: Colors.grey[700],
                      unselectedLabelColor: Color(0xffCCCCCC),
                      indicatorColor: Colors.grey[700],
                      controller: _tabController,
                      indicatorWeight: 2.0,
                      isScrollable: true,
                      tabs: <Tab>[
                        Tab(text: AppLocalizations.of(context).home),
                        Tab(text: AppLocalizations.of(context).info),
                        Tab(text: AppLocalizations.of(context).foto),
                        Tab(text: AppLocalizations.of(context).classifica),
                        Tab(text: AppLocalizations.of(context).followers),
                      ],
                    )),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(controller: _tabController, children: <Widget>[
                _isLoading
                    ? Center(child: WidgetUtils.spinLoader())
                    : ContestHomeView(
                        contest: widget.contest,
                        onTapAllComments: (EntityBase element, {bool edit}) =>
                            _showCommentsPage(element, edit: edit),
                        onTapFollowers: () => _selectTab(4),
                        onTapUser: _showUserPage,
                        onTapInfo: () => _selectTab(1),
                        onTapLeaders: () => _selectTab(3),
                        onTapPhotoLeaders: _showPhotoLeadersPage,
                        onTapPhoto: _showPhotoSlidePage,
                        onTapPhotos: () => _selectTab(2),
                      ),
                Container(
                    color: Colors.white,
                    child: ContestDetailsView(widget.contest, _showUserPage)),
                Container(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: LoadingListView<Photo>(_loadPhotos,
                        elements: widget.contest.photos,
                        initialRefresh: true,
                        widgetAdapter: adaptPhotos,
                        indexer: (Photo e) => e.id)),
                Container(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16.0, right: 16.0),
                    child: LoadingListView<Photo>(_loadLeaders,
                        elements: widget.contest.leaders,
                        initialRefresh: true,
                        widgetAdapter: adaptLeaders,
                        indexer: (Photo e) => e.id)),
                Container(
                    color: Colors.white,
                    child: FollowersView(
                      element: widget.contest,
                      type: ListUserType.contestFollowers,
                    ))
              ])),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
