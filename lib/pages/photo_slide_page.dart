import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/photos/photo_toolbar.dart';
import 'package:shuttertop/ui/photos/reportdelete_button.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/ui/photos/photo_view.dart';
import 'package:shuttertop/ui/widget/page_transformer.dart';

class PhotoSlidePage extends StatefulWidget {
  final List<Photo> photos;
  final int index;
  final Map<String, dynamic> params;
  final IPhotoable element;

  const PhotoSlidePage(this.photos,
      {this.params, this.index, @required this.element, Key key})
      : super(key: key);

  static const String routeName = '/photo_slide';

  @override
  _PhotoSlidePageState createState() => new _PhotoSlidePageState();
}

class _PhotoSlidePageState extends State<PhotoSlidePage> {
  PageController _pageController;
  bool _fullScreen = false;
  bool _noScroll = false;
  final int pageThreshold = 2;
  final int pageSize = 30;
  Map<int, int> index = <int, int>{};
  Future<Null> request;
  int totObjects;
  int pageSelected;
  int loadingId = -1;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    try {
      print("params ${widget.params}");
      pageSelected = widget.index;
      _pageController =
          new PageController(viewportFraction: 1.0, initialPage: pageSelected);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Future<RequestListPage<Photo>> _loadPhotos(int page) async {
    widget.params["page"] = page.toString();
    return (await shuttertop.photoRepository.fetchByParams(widget.params));
  }

  void _showContestPage(Contest contest, {bool join = false}) {
    WidgetUtils.showContestPage(context, contest,
        join: join, showComments: false);
    setState(() {});
  }

  void _showCommentsPage(EntityBase element, {bool edit}) {
    WidgetUtils.showCommentsPage(context, element, edit: edit);
    setState(() {});
  }

  void _showUserPage(User user) {
    WidgetUtils.showUserPage(context, user);
    setState(() {});
  }

  Future<Null> _notifyThreshold() async {
    lockedLoadNext();
  }

  void lockedLoadNext() {
    if (request == null) {
      request = loadNext().then((Null e) {
        request = null;
      });
    }
  }

  Future<Null> loadNext() async {
    int page = 0;
    if (totObjects != null || widget.photos.length > pageSize)
      page = (widget.photos.length / pageSize).ceil();
    print(
        "loadNext: page: $page photos: ${widget.photos.length} pageSize: $pageSize");
    final RequestListPage<Photo> fetched = await _loadPhotos(page);

    if (mounted && fetched != null) {
      setState(() {
        print("loadNext entries: ${fetched.entries.length}");
        addObjects(fetched.entries);
        totObjects = fetched.totalEntries;
        //_isComplete = (fetched.entries.length == 0);
      });
    }
  }

  void addObjects(Iterable<Photo> photos) {
    photos.forEach((Photo photo) {
      if (!widget.photos.any((Photo p) => p == photo)) {
        widget.photos.add(photo);
        print("photo inesistente ${photo.id}");
      }
    });
  }

  Future<bool> _handleFullScreenNotification() async {
    await SystemChrome.setEnabledSystemUIOverlays(
        !_fullScreen ? <SystemUiOverlay>[] : SystemUiOverlay.values);
    _isChanging = true;
    _fullScreen = !_fullScreen;
    _noScroll = false;
    if (mounted) setState(() {});
    new Future<void>.delayed(const Duration(milliseconds: 200), () {
      _pageController.jumpToPage(pageSelected);
      _isChanging = false;
      if (mounted) setState(() {});
    });
    return true;
  }

  bool _isWithOnePhoto() {
    try {
      return widget.photos.length < 2;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return true;
    }
  }

  Future<Null> _vote() async {
    if (await shuttertop.activityRepository.vote(widget.photos[pageSelected]))
      setState(() {});
    else
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(AppLocalizations.of(context).contestTerminato)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _fullScreen ? Colors.black : Colors.white,
        body: _fullScreen
            ? _getBody()
            : NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      //centerTitle: true,
                      actions: <Widget>[
                        ReportDeleteButton(widget.photos[pageSelected],
                            element: widget.element)
                      ],
                      iconTheme: IconThemeData(color: Colors.black),
                      title: ListView(children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(top: 5.0, bottom: 0.0),
                            child: Text(widget.element?.name ?? "",
                                style: Styles.header)),
                        Text(
                          widget.params["order"] == "top"
                              ? AppLocalizations.of(context).fotoInOrdineDiVoti
                              : AppLocalizations.of(context)
                                  .fotoInOrdineDiInserimento,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[600],
                          ),
                        )
                      ]),
                      forceElevated: true,
                      elevation: _isWithOnePhoto() ? 1.0 : 0.0,
                      pinned: true,
                      floating: true,
                      snap: false,
                    )
                  ];
                },
                body: Stack(children: <Widget>[
                  Container(
                      padding:
                          _isWithOnePhoto() ? null : EdgeInsets.only(top: 63),
                      child: _getBody()),
                  Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                          decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(0.0, -1.0),
                                  spreadRadius: 3.0,
                                  blurRadius: 3.0

                                  //blurRadius: shadowRadius,
                                  ),
                            ],
                            color: Colors.white,

                            //border: Border(top: BorderSide(width: 1.0, color: Colors.black12),),
                          ),
                          child: Column(
                            children: <Widget>[
                              _isWithOnePhoto()
                                  ? null
                                  : Container(
                                      height: 63.0,
                                      padding: EdgeInsets.fromLTRB(
                                          8.0, 12.0, 8.0, 11.0),
                                      child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: widget.photos
                                              .map<Widget>((Photo p) =>
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          right: 1.0,
                                                          left: 1.0),
                                                      padding: EdgeInsets.only(
                                                          bottom: 2.0),
                                                      decoration: BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  width: 2.0,
                                                                  color: p ==
                                                                          widget.photos[
                                                                              pageSelected]
                                                                      ? AppColors
                                                                          .brandPrimary
                                                                      : Colors
                                                                          .transparent))),
                                                      child: InkWell(
                                                          onTap: () =>
                                                              _showPhotoPage(p),
                                                          child: Container(
                                                              height: 40,
                                                              width: 40,
                                                              color: AppColors
                                                                  .placeHolder,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: p.getImageUrl(
                                                                    ImageFormat
                                                                        .thumb),
                                                                fadeInDuration:
                                                                    Constants
                                                                        .fadeInDuration,
                                                                fit: BoxFit
                                                                    .cover,
                                                              )))))
                                              .toList()),
                                    ),
                              /*PhotoToolbar(widget.photos[pageSelected],
                                  vote: _vote),*/
                            ].where((Widget e) => e != null).toList(),
                          )))
                ])));
  }

  Widget _getBody() {
    print("photo_slide_page isChanging: $_isChanging");
    return NotificationListener<FullScreenNotification>(
      onNotification: (FullScreenNotification notification) {
        _handleFullScreenNotification();
        return true;
      },
      child: PageTransformer(
        pageViewBuilder:
            (BuildContext context, PageVisibilityResolver visibilityResolver) {
          return PageView.builder(
            controller: _pageController,
            physics: _noScroll ? new NeverScrollableScrollPhysics() : null,
            onPageChanged: (int index) async {
              if (index != pageSelected) {
                setState(() {
                  pageSelected = index;
                });
              }
            },
            itemCount: widget.photos.length,
            itemBuilder: (BuildContext context, int index) {
              final PageVisibility pageVisibility =
                  visibilityResolver.resolvePageVisibility(index);
              if ((totObjects == null ||
                  (totObjects > widget.photos.length &&
                      index + pageThreshold > widget.photos.length)))
                _notifyThreshold();
              return _isChanging
                  ? Container()
                  : PhotoView(
                      onTapAllComments: _showCommentsPage,
                      onTapUser: _showUserPage,
                      onTapContest: _showContestPage,
                      onScaling: onScaling,
                      photo: widget.photos[index],
                      pageVisibility: pageVisibility,
                      showComments: false,
                      loadingId: loadingId,
                      parentElement: widget.element,
                      fullScreen: _fullScreen,
                    );
            },
          );
        },
      ),
    );
  }

  Future<Null> onScaling(bool isScaling) async {
    if (_noScroll != isScaling) setState(() => _noScroll = isScaling);
  }

  void _showPhotoPage(Photo photo) async {
    final int idx = widget.photos.indexWhere((Photo p) => p.id == photo.id);
    loadingId = photo.id;
    await _pageController.animateToPage(
      idx,
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 600),
    );
    loadingId = -1;
  }
}
