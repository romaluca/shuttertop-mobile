import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/functions.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/ui/photos/photo_toolbar.dart';
import 'package:shuttertop/ui/photos/reportdelete_button.dart';
import 'package:shuttertop/ui/widget/highlighted_icon.dart';
import 'package:shuttertop/ui/widget/tag.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/activities/comment_block.dart';
import 'package:shuttertop/ui/contests/contest_list_item.dart';
import 'package:shuttertop/ui/photos/photo_fullscreen.dart';
import 'package:shuttertop/ui/users/user_list_item.dart';
import 'package:shuttertop/ui/widget/block.dart';
import 'package:shuttertop/ui/widget/page_transformer.dart';
import 'package:shuttertop/ui/users/users_row.dart';
import 'package:shuttertop/ui/widget/simple_page.dart';
import 'package:shuttertop/ui/users/followers_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoView extends StatefulWidget {
  const PhotoView(
      {@required this.photo,
      @required this.onTapAllComments,
      @required this.onTapContest,
      @required this.onTapUser,
      this.onScaling,
      this.showToolbar = false,
      this.loadingId = -1,
      this.parentElement,
      this.pageVisibility,
      this.fullScreen,
      @required this.showComments});
  final Photo photo;
  final IPhotoable parentElement;
  final bool showToolbar;
  final bool fullScreen;
  final PageVisibility pageVisibility;
  final ShowCommentsPage onTapAllComments;
  final ShowContestPage onTapContest;
  final ShowUserPage onTapUser;
  final Function onScaling;
  final bool showComments;
  final int loadingId;

  static const String routeName = '/photo';

  @override
  _PhotoViewState createState() => new _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> with WidgetsBindingObserver {
  ScrollController _listViewController;

  bool fullScreenInfo = false;
  bool showHeart = false;
  double photoHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.loadingId == -1 || widget.loadingId == widget.photo.id) {
      _connect();
      _loadPhoto();
    }
    _listViewController = new ScrollController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _leave();
    _listViewController.dispose();
    super.dispose();
  }

  Future<Null> _connect() async {
    /*shuttertop.photoRepository.join(widget.photo,
        onVoted: (ResponseStatus status, [dynamic result]) {},
        onComment: () {});*/
  }

  Future<Null> _leave() async {
    //shuttertop.photoRepository.leave(widget.photo);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("---didChangeAppLifecycleState state=${state.toString()}");
    if (state == AppLifecycleState.paused)
      shuttertop.disconnect(true);
    else if (state == AppLifecycleState.resumed) _connect();
  }

  Future<Null> _loadPhoto() async {
    await shuttertop.photoRepository
        .get(widget.photo.slug, photo: widget.photo);
    if (widget.showComments) widget.onTapAllComments(widget.photo, edit: false);
    if (mounted) setState(() {});
  }

  /*
  Future<Null> _followUser() async {
    shuttertop.userRepository
        .follow(shuttertop,
          widget.photo.user, (bool error, [String errorDescription]) =>
            setState(() {}));
  }
*/
  Future<Null> _vote() async {
    if (await shuttertop.activityRepository.vote(widget.photo))
      setState(() => showHeart = widget.photo.voted);
    else
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(AppLocalizations.of(context).contestTerminato)));
  }

  /*
  void _onVoted(Map<String, dynamic> resp) {
    setState(() {
      widget.photo.voted = resp["voted"];
      widget.photo.votesCount = resp["votes_count"];
      widget.photo.position = resp["position"];
      if (widget.photo.voted) {
        if (!widget.photo.tops
            .any((User user) => user.id == shuttertop.currentSession.user.id))
          widget.photo.tops.add(shuttertop.currentSession.user);
      } else
        widget.photo.tops.removeWhere(
            (User user) => user.id == shuttertop.currentSession.user.id);
    });
  }

  void _onNewComment(Map<String, dynamic> resp) {
    print("on new_comment $resp");
    //onCreateCommentComplete(new Comment.fromMap(resp));
  }*/

  Future<Null> _onRefresh() {
    final Completer<Null> completer = new Completer<Null>();
    _loadPhoto();
    completer.complete(null);
    return completer.future;
  }

  double _getImageHeight() {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double maxPhotoHeight = mediaQueryData.size.height -
        mediaQueryData.padding.top -
        (kToolbarHeight * (widget.pageVisibility == null ? 1 : 3.2));
    double photoHeight = widget.photo.height != null
        ? MediaQuery.of(context).size.width *
            widget.photo.height /
            widget.photo.width
        : null;
    if (photoHeight != null && photoHeight > maxPhotoHeight)
      photoHeight = maxPhotoHeight;
    return photoHeight;
  }

  Widget _buildImage() {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double top = widget.showToolbar ? mediaQueryData.padding.top : 0.0;

    final FadeInImage photo = FadeInImage(
      placeholder: new MemoryImage(kTransparentImage),
      image: new CachedNetworkImageProvider(
          widget.photo.getImageUrl(ImageFormat.medium)),
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 250),
    );

    photoHeight = _getImageHeight() ??
        (photo.height != null && photo.height > photo.width ? 550.0 : 250.0);

    return new Positioned(
      top: top -
          (_listViewController.hasClients
              ? _listViewController.offset / 3
              : 0.0),
      left: widget.pageVisibility != null &&
              widget.pageVisibility.pagePosition != 1
          ? -widget.pageVisibility.pagePosition * 200
          : 0.0,
      height: photoHeight,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[AppColors.background, Colors.grey[400]])),
        height: photoHeight,
        width: MediaQuery.of(context).size.width,
        child: photo,
      ),
    );
  }

  void _notifyFullScreen({Function callBack}) {
    print("_notifyFullScreen");
    new FullScreenNotification(callBack: callBack).dispatch(context);
  }

  void _notifyScaling(bool isScaling) {
    print("_notifyScaling");
    if (widget.onScaling != null) widget.onScaling(isScaling);
  }

  bool _onNotifyAnimation(AnimationNotification notification) {
    setState(() => showHeart = false);
    return false;
  }

  void onUserFollow(bool followed) {
    setState(() => widget.photo.user.followed = followed);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double top = mediaQueryData.padding.top;

    return widget.fullScreen
        ? NotificationListener<EntityNotification>(
            onNotification: _onNotify,
            child: PhotoFullscreen(
              photo: widget.photo,
              onTapAllComments: widget.onTapAllComments,
              onTapUser: widget.onTapUser,
              fullScreenInfo: fullScreenInfo,
              notifyFullScreen: _notifyFullScreen,
              notifyScaling: _notifyScaling,
              notifyFullScreenInfo: () =>
                  setState(() => fullScreenInfo = !fullScreenInfo),
            ))
        : RefreshIndicator(
            child: Stack(
                //fit: StackFit.expand,
                children: <Widget>[
                  _buildImage(),
                  showHeart
                      ? Positioned(
                          top: 0.0,
                          height: photoHeight,
                          left: 0.0,
                          right: 0.0,
                          child: NotificationListener<AnimationNotification>(
                              onNotification: _onNotifyAnimation,
                              child: HighLightedIcon(
                                Icons.favorite,
                                color: Colors.white70,
                                size: 150.0,
                              )))
                      : Container(),
                  Positioned(
                      top: -top - 10,
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child:
                          ListView(controller: _listViewController, children: <
                              Widget>[
                        InkWell(
                          onTap: _notifyFullScreen,
                          onDoubleTap: () {
                            if (!widget.photo.voted) _vote();
                          },
                          child: Container(
                            height: _getImageHeight() ?? 224.0,
                          ),
                        ),
                        Container(
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height - 250.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0)),
                              /*boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: Offset(0.0, 1.0),
                                    spreadRadius: 2.0,
                                    blurRadius: 2.0

                                    //blurRadius: shadowRadius,
                                    ),
                              ],*/

                              //border: Border(top: BorderSide(width: 1.0, color: Colors.black12),),
                            ),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                      children: <Widget>[
                                    PhotoToolbar(
                                      widget.photo,
                                      vote: _vote,
                                      shadowRadius: 0.0,
                                    ),
                                    _buildUserRow(),
                                    _buildContestRow(),
                                    _buildPhotoDetails(),
                                    _buildTops(),
                                    Container(
                                        padding: EdgeInsets.only(
                                            bottom:
                                                widget.pageVisibility == null
                                                    ? 50.0
                                                    : 130.0),
                                        child: CommentBlock(
                                            widget.photo,
                                            widget.onTapAllComments,
                                            widget.onTapUser)),
                                  ].where((Widget e) => e != null).toList()),
                                ])),
                      ])),
                  _buildAppBar(),
                ]),
            onRefresh: _onRefresh);
  }

  Widget _buildAppBar() {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);

    if (!widget.showToolbar) return Container();
    double backOpacity = _listViewController.hasClients
        ? (_listViewController.offset > 250
            ? 1.0
            : (_listViewController.offset / 250.0))
        : 0.0;
    if (backOpacity > 1.0) backOpacity = 0.0;
    if (backOpacity < 0.0) backOpacity = 0.0;
    final Color iconColor = Colors.black;
    return new GestureDetector(
        onTap: _notifyFullScreen,
        child: Material(
            color: Colors.transparent,
            elevation: backOpacity > 0.3 ? 1.0 : 0.0,
            child: Container(
              alignment: Alignment.centerLeft,
              color: Colors.white.withOpacity(backOpacity),
              height: kToolbarHeight + mediaQueryData.padding.top,
              padding: EdgeInsets.only(top: mediaQueryData.padding.top),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    BackButton(
                      color: iconColor,
                    ),
                    ReportDeleteButton(
                      widget.photo,
                      element: widget.parentElement,
                    )
                  ]),
            )));
  }

  Widget _buildTops() {
    if (widget.photo != null && widget.photo.votesCount > 0)
      return UsersRow(widget.photo.tops, widget.photo.votesCount,
          AppLocalizations.of(context).iSostenitori, _onTapTops);
    else
      return null;
  }

  void _onTapTops() {
    Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: FollowersView.routeName),
            builder: (BuildContext context) => SimplePage(
                AppLocalizations.of(context).iSostenitori,
                FollowersView(
                  element: widget.photo,
                  type: ListUserType.photoTops,
                ))));
    setState(() {});
  }

  Widget _buildContestRow() {
    return (widget.parentElement is Contest) || widget.photo.contest == null
        ? null
        : ContestListItem(widget.photo.contest, widget.onTapContest);
  }

  Widget _buildPhotoDetails() {
    if (widget.photo.exposureTime == null &&
        widget.photo.model == null &&
        widget.photo.fNumber == null &&
        widget.photo.focalLength == null &&
        widget.photo.photographicSensitivity == null)
      return Container(
        height: 0.0,
        width: 0.0,
      );
    final int expTime =
        widget.photo.exposureTime != null && widget.photo.exposureTime > 0
            ? (1 / widget.photo.exposureTime).round()
            : null;
    final TextStyle style = new TextStyle(color: AppColors.text);
    return Block(
        title: AppLocalizations.of(context).infoFoto,
        child: Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(0.0),
            child: Column(
                children: <Widget>[
              widget.photo.model != null
                  ? new Text(
                      widget.photo.model,
                      style: TextStyle(color: Colors.grey[800]),
                    )
                  : null,
              Container(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      widget.photo.fNumber == null
                          ? null
                          : new Tag(
                              value: "f/${widget.photo.fNumber}",
                              label:
                                  AppLocalizations.of(context).rapportoFocale,
                              //style: style,
                            ),
                      expTime == null
                          ? null
                          : new Tag(
                              value: "1/$expTime sec.",
                              label: AppLocalizations.of(context)
                                  .tempoEsposizione),
                      widget.photo.focalLength == null
                          ? null
                          : new Tag(
                              value: "${widget.photo.focalLength}mm",
                              label:
                                  AppLocalizations.of(context).lunghezzaFocale),
                      widget.photo.photographicSensitivity == null
                          ? null
                          : new Text(
                              "ISO${widget.photo.photographicSensitivity}",
                              style: style),
                    ].where((Widget e) => e != null).toList(),
                  ))
            ].where((Widget e) => e != null).toList())));
  }

  bool _onNotify(EntityNotification notification) {
    setState(() {});
    return false;
  }

  Widget _buildUserRow() {
    return (widget.parentElement is User) || widget.photo.user == null
        ? null
        : NotificationListener<EntityNotification>(
            onNotification: _onNotify,
            child: Container(
              child: UserListItem(widget.photo.user, widget.onTapUser),
            ));
  }
}
