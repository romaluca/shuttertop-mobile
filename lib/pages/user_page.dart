import 'dart:async';

import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/pages/element_photos_page.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/contests/contest_grid.dart';
import 'package:shuttertop/ui/contests/contest_list.dart';
import 'package:shuttertop/ui/contests/contest_list_item_vertical.dart';
import 'package:shuttertop/ui/contests/contest_loading_grid.dart';
import 'package:shuttertop/ui/users/followers_view.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/contests/contest_list_item.dart';
import 'package:shuttertop/pages/photo_slide_page.dart';
import 'package:shuttertop/ui/users/user_follow_btn.dart';
import 'package:shuttertop/ui/users/user_stats.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/photos/photos_row.dart';
import 'package:shuttertop/ui/users/users_row.dart';
import 'package:shuttertop/ui/widget/rounded_clipper.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/ui/widget/simple_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class UserPage extends StatefulWidget {
  const UserPage(this.user,
      {Key key, this.withBackButton = true, this.showComments = false})
      : super(key: key);

  final User user;
  final bool withBackButton;
  final bool showComments;

  static const String routeName = '/user';

  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ScrollController _listViewController = new ScrollController();

  bool _isLoading;
  int _contestsAdded = 0;

  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addObserver(this);
      _isLoading = true;
      _connect();
      print("USERPAGE - ${widget.user.slug}");
      _loadUser(widget.user.slug).then<Null>((dynamic e) {
        if (widget.showComments)
          WidgetUtils.showCommentsPage(context, widget.user, edit: false);
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  void dispose() {
    _leave();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Null> _connect() async {
    //shuttertop.userRepository.join(widget.user);
  }

  Future<Null> _leave() async {
    //shuttertop.userRepository.join(widget.user);
  }

  Future<Null> _loadUser(String slug) async {
    await shuttertop.userRepository.get(slug, user: widget.user);
    setState(() {
      _isLoading = false;
    });
  }

  bool _onNotify(EntityNotification notification) {
    print("UserPage _onNotify ${widget.user.followersCount}");

    setState(() {});
    return false;
  }

  Future<Null> _onChat() async {
    await WidgetUtils.showCommentsPage(context, widget.user, edit: true);
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("---user didChangeAppLifecycleState state=${state.toString()}");
    if (state == AppLifecycleState.paused)
      _leave();
    else if (state == AppLifecycleState.resumed) _connect();
  }

  bool _handleScrollNotification() {
    setState(() {});
    return true;
  }

  Photo _getCover() {
    try {
      return widget.user.bestPhoto;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Photo cover = _getCover();
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double coverHeight = mediaQueryData.padding.top + 180.0;

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: _isLoading || widget.user.name == null
            ? Center(child: WidgetUtils.spinLoader())
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) =>
                    _handleScrollNotification(),
                child: Container(
                    child: Stack(children: <Widget>[
                  Positioned(
                    child: cover != null
                        ? FadeInImage(
                            height: coverHeight,
                            width: MediaQuery.of(context).size.width,
                            placeholder: new MemoryImage(kTransparentImage),
                            image: new CachedNetworkImageProvider(
                                cover.getImageUrl(ImageFormat.normal)),
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 250),
                          )
                        : Container(
                            height: coverHeight,
                            color: Colors.black87,
                          ),
                  ),
                  ListView(
                    controller: _listViewController,
                    children: <Widget>[
                      _buildTitle(),
                      Container(
                          color: Colors.white,
                          child: PhotosRow(
                              widget.user?.photos,
                              widget.user?.photosCount,
                              _showPhotoListPage,
                              AppLocalizations.of(context).leSueFoto,
                              onElementTap: _onPhotoTap)),
                      Container(
                          color: Colors.white, child: _buildContestsCreated()),
                      Container(
                          color: Colors.white,
                          child: UsersRow(
                              widget.user?.followers,
                              widget.user?.followersCount,
                              AppLocalizations.of(context).followers,
                              _onFollowersTap)),
                      widget.user.follows.isEmpty
                          ? null
                          : Container(
                              color: Colors.white,
                              child: UsersRow(
                                  widget.user.follows,
                                  widget.user.followsUserCount,
                                  AppLocalizations.of(context).following,
                                  _onFollowsTap)),
                    ].where((Widget ele) => ele != null).toList(),
                  ),
                  _buildAppBar(widget.withBackButton)
                ]))));
  }

  void _onFollowersTap() {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: FollowersView.routeName),
            builder: (BuildContext context) => SimplePage(
                  widget.user?.name,
                  FollowersView(
                    element: widget.user,
                    type: ListUserType.userFollowers,
                  ),
                  subtitle:
                      AppLocalizations.of(context).followers.toLowerCase(),
                )));
    setState(() {});
  }

  void _onFollowsTap() {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: FollowersView.routeName),
            builder: (BuildContext context) => SimplePage(
                AppLocalizations.of(context).userFollows(widget.user.name),
                FollowersView(
                  element: widget.user,
                  type: ListUserType.userFollows,
                ))));
    setState(() {});
  }

  void _showPhotoListPage() {
    print("_photoPhotoListPage");
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: ElementPhotosPage.routeName),
            builder: (BuildContext context) => ElementPhotosPage(widget.user)));
    setState(() {});
  }

  void _showContestPage(Contest contest, {bool join = false}) {
    WidgetUtils.showContestPage(context, contest,
        join: join, showComments: false);
    setState(() {});
  }

  void _onPhotoTap(Photo photo) {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: PhotoSlidePage.routeName),
            builder: (BuildContext context) => PhotoSlidePage(
                    widget.user.photos,
                    element: widget.user,
                    index: widget.user.photos.indexOf(photo),
                    params: <String, dynamic>{
                      "user_id": widget.user.id,
                      "order": "top"
                    })));
    setState(() {});
  }

  Widget _buildTitle() {
    return Container(
      //height: 280.0,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 180.0,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(color: Colors.white),
          ),
          Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 140.0, left: 0.0, right: 0.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(45.0))),
                  child: Container(
                      padding:
                          EdgeInsets.only(top: kToolbarHeight, bottom: 8.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 12.0, bottom: 16.0),
                            child: Text(
                              widget.user.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Raleway",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22.0,
                                  color: Colors.grey[800]),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 20.0, left: 16.0, right: 16.0),
                            child: widget.user != shuttertop.currentSession.user
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                        Expanded(
                                            child: new NotificationListener<
                                                    EntityNotification>(
                                                onNotification: _onNotify,
                                                child: UserFollowBtn(
                                                    widget.user,
                                                    margin: EdgeInsets.only(
                                                        right: 4),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0)))),
                                        Expanded(
                                            child: InkWell(
                                                onTap: () => _onChat(),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.only(
                                                      top: 3.0, left: 4.0),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey[200],
                                                        width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                  ),
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .scrivigli,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontFamily: "Raleway",
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14.0)),
                                                ))),
                                      ])
                                : Container(),
                          ),
                          _buildStats(),
                        ],
                      )))),
          InkWell(
            onTap: () =>
                WidgetUtils.showImageFullScreenPage(context, widget.user),
            child: Container(
              margin: EdgeInsets.only(top: kToolbarHeight),
              alignment: Alignment.center,
              child: Avatar(
                widget.user.getImageUrl(ImageFormat.medium),
                border: 8.0,
                shadow: 0.0,
                backColor: Colors.white,
              ),
            ),
          ),
        ].where((Widget e) => e != null).toList(),
      ),
    );
  }

  Widget _buildAppBar(bool withBackButton) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double statusBarHeight = mediaQueryData.padding.top;

    final Color color =
        (_listViewController.hasClients && _listViewController.offset > 180
            ? Colors.grey[800]
            : Colors.white);
    double colorOpacity = _listViewController.hasClients
        ? (_listViewController.offset > 180
            ? 1.0
            : (_listViewController.offset / 180.0))
        : 0.0;
    if (colorOpacity > 1.0) colorOpacity = 1.0;
    if (colorOpacity < 0.0) colorOpacity = 0.0;
    return Material(
        elevation: color != Colors.white ? 1.0 : 0.0,
        color: Colors.transparent,
        child: Container(
            alignment: Alignment.centerLeft,
            color: Colors.white.withOpacity(colorOpacity),
            height: kToolbarHeight + statusBarHeight,
            padding: EdgeInsets.only(top: statusBarHeight),
            width: MediaQuery.of(context).size.width,
            child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            widget.user.name,
                            style: TextStyle(
                                color: color == Colors.white
                                    ? Colors.transparent
                                    : Colors.grey[800],
                                fontSize: 20.0,
                                fontFamily: "Raleway",
                                fontWeight: FontWeight.w700),
                          ))),
                  shuttertop.currentSession.user == widget.user
                      ? Positioned(
                          top: 0.0,
                          right: 0.0,
                          bottom: 0.0,
                          child: IconButton(
                            // action button
                            icon: Icon(
                              OMIcons.settings,
                              color: color,
                            ),
                            onPressed: () {
                              _showSettingsPage();
                            },
                          ))
                      : null,
                  withBackButton
                      ? Positioned(
                          left: 0.0,
                          bottom: 0.0,
                          top: 0.0,
                          child: BackButton(
                            color: color,
                          ))
                      : null,
                ].where((Widget e) => e != null).toList())));
  }

  Widget _buildStats() {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
              Colors.white,
              Colors.grey[50],
              Colors.grey[100],
              Colors.grey[100],
              Colors.grey[100]
            ])),
        child: UserStats(
          widget.user,
        ));
  }

  int _getContestsLength() {
    try {
      return widget.user.contests.length;
    } catch (error) {
      return 0;
    }
  }

  Widget _buildContestsCreated() {
    if (_getContestsLength() == 0) return Container(width: 0.0, height: 0.0);
    return Block(
        title: "Contest creati",
        subtitle: (widget.user?.contestCount ?? 0).toString(),
        onTapAll: _getContestsLength() > 3 ? _showContestsPage : null,
        child: ContestGrid(
          widget.user.contests,
          _showContestPage,
        ));
  }

  void _showContestsPage() {
    WidgetUtils.showContestsCreatedPage(context, widget.user);
    setState(() {});
  }

  Future<Null> _showSettingsPage() async {
    await WidgetUtils.showSettingsPage(context);
    setState(() {
      widget.user.name = shuttertop.currentSession.user.name;
      widget.user.upload = shuttertop.currentSession.user.upload;
    });
    setState(() {});
  }
}
