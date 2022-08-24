import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/topic.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/contests/contest_thumb.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/ui/activities/comment_list_item.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:shuttertop/ui/widget/load_list_view.dart';
import 'package:transparent_image/transparent_image.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage(this.element, {@required this.autoFocus, this.topic});
  final EntityBase element;
  final bool autoFocus;
  final Topic topic;

  static const String routeName = '/comments';

  @override
  _CommentsPageState createState() => new _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isTyping = false;
  StreamController<Comment> _postStreamController;
  ScrollController scrollController;
  final TextEditingController _textController = TextEditingController();
  List<Comment> elements;
  StreamSubscription<CommentEvent> subscription;

  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addObserver(this);
      elements = <Comment>[];
      _connect();
      _postStreamController = new StreamController<Comment>();
      scrollController = new ScrollController();
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
    print("initState");
    subscription =
        shuttertop.eventBus.on<CommentEvent>().listen((CommentEvent e) {
      print("new comment ${e.uId}");
      if (e.uId == widget.element.uId) {
        print("on new_comment");
        widget.element.comments.add(e.comment);
        _postStreamController.add(widget.element.comments.last);
        if (widget.topic != null) {
          widget.topic.lastComment = widget.element.comments.last;
          widget.topic.readAt = widget.topic.lastComment.insertedAt
              .add(Duration(milliseconds: 1));
        }
      }
    });
  }

  @override
  void dispose() {
    _leave();
    shuttertop.currentEntityComments = null;
    WidgetsBinding.instance.removeObserver(this);
    if (subscription != null) subscription.cancel();
    subscription = null;
    super.dispose();
  }

  Future<Null> _connect() async {
    shuttertop.currentEntityComments = widget.element;
  }

  Future<Null> _leave() async {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("----comments didChangeAppLifecycleState state=${state.toString()}");
    if (state == AppLifecycleState.paused) {
      shuttertop.disconnect(true);
      shuttertop.currentEntityComments = null;
    } else if (state == AppLifecycleState.resumed) _connect();
  }

  Future<RequestListPage<Comment>> _loadComments(int page) async {
    final RequestListPage<Comment> ret =
        await shuttertop.commentRepository.fetch(widget.element);
    if (widget.topic != null) widget.topic.readAt = DateTime.now();
    return ret;
  }

  Future<Null> _handleSubmitted() async {
    final String body = _textController.text;
    _textController.clear();
    setState(() => _isTyping = false);
    await shuttertop.commentRepository.create(body, widget.element);
  }

  void _showUserPage(User user) async {
    await WidgetUtils.showUserPage(context, user);
    setState(() {});
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

  String _getName() {
    if (widget.element is Photo) {
      final Photo p = widget.element;
      return "${p.user?.name}";
    } else {
      return widget.element.name;
    }
  }

  Widget _getImageThumb() {
    try {
      if (widget.element is User)
        return Avatar(widget.element.getImageUrl(ImageFormat.thumb),
            backColor: Colors.grey, size: 40.0);
      else if (widget.element is Photo)
        return Container(
            width: 40.0,
            height: 40.0,
            color: AppColors.placeHolder,
            child: CachedNetworkImage(
              imageUrl: widget.element.getImageUrl(ImageFormat.thumb_small),
              fit: BoxFit.cover,
              fadeInDuration: Constants.fadeInDuration,
            ));
      else if (widget.element is Contest)
        return ContestThumb(widget.element, ContestThumbType.microsquare);
      else
        return Container();
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  iconTheme: IconThemeData(color: Colors.black),
                  titleSpacing: 0.0,
                  title: Container(
                      child: Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: _getImageThumb()),
                      Flexible(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            Text(_getName(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Styles.header),
                            widget.element is Photo
                                ? Text(
                                    "@ ${((widget.element as Photo).contest ?? widget.topic?.contest)?.name}",
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15.0))
                                : Container()
                          ])),
                    ],
                  )),
                  pinned: true,
                  elevation: 1.0,
                  snap: false,
                  floating: false,
                )
              ];
            },
            body: Column(children: <Widget>[
              Flexible(
                  child: LoadingListView<Comment>(
                _loadComments,
                elements: elements,
                widgetAdapter: adapt,
                withRefresh: false,
                indexer: (Comment e) => e.id,
                topStream: _postStreamController.stream,
                scrollController: scrollController,
                reverse: true,
              )),
              _buildTextComposer(),
            ])));
  }

  Widget adapt(List<Comment> comment, int index) {
    return CommentListItem(comment[index], _showUserPage);
  }

  Widget _buildTextComposer() {
    return Material(
        elevation: 0.0,
        color: Colors.white,
        child: Container(
          color: Colors.transparent,
          margin:
              EdgeInsets.only(left: 7.0, right: 12.0, bottom: 25.0, top: 10.0),
          child: Row(children: <Widget>[
            Expanded(
                child: Material(
              elevation: 0.0,
              color: Colors.transparent,
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    border: Border.all(color: Colors.grey[300], width: 1.0),
                    color: Colors.grey[50],
                  ),
                  height: 46.0,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 0.0, right: 5.0),
                  child: Row(
                      children: <Widget>[
                    Container(
                        width: 36.0,
                        height: 36.0,
                        color: Colors.transparent,
                        margin: EdgeInsets.only(right: 20.0, left: 5.0),
                        child: Avatar(
                          _getUserImage(),
                          size: 36.0,
                          backColor: Colors.grey,
                        )),
                    Expanded(
                        child: TextField(
                            autofocus: widget.autoFocus,
                            controller: _textController,
                            onChanged: (String text) {
                              setState(() => _isTyping = true);
                            },
                            decoration: InputDecoration.collapsed(
                                hintStyle: TextStyle(color: Colors.black54),
                                hintText: AppLocalizations.of(context)
                                    .sputaIlRospo))),
                    _isTyping || true
                        ? InkWell(
                            child: Container(
                                padding:
                                    EdgeInsets.only(left: 12.0, right: 8.0),
                                child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.grey[700],
                                  size: 26.0,
                                )),
                            onTap: _handleSubmitted)
                        : null
                  ].where((Widget e) => e != null).toList())),
            )),
          ]),
        ));
  }
}
