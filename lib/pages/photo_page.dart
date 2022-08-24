import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:shuttertop/misc/notifications.dart';
import 'package:shuttertop/ui/photos/photo_view.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage(this.photo,
      {Key key, this.showComments = false, this.parentElement})
      : super(key: key);

  final Photo photo;
  final bool showComments;

  static const String routeName = '/photo_page';

  final IPhotoable parentElement;

  @override
  _PhotoPageState createState() => new _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  bool _fullScreen = false;
  Photo photo;

  @override
  void initState() {
    super.initState();
    try {
      shuttertop.photoRepository
          .get(widget.photo.slug)
          .then((Photo p) => setState(() => photo = p));
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  void _showContestPage(Contest contest, {@required bool join}) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _fullScreen ? Colors.black : Colors.white,
        body: photo?.upload == null
            ? Center(child: WidgetUtils.spinLoader())
            : NotificationListener<ScrollNotification>(
                child: NotificationListener<FullScreenNotification>(
                    onNotification: (FullScreenNotification notification) {
                      _handleFullScreenNotification(notification);
                      return true;
                    },
                    child: PhotoView(
                        photo: photo,
                        showToolbar: true,
                        parentElement: widget.parentElement,
                        onTapContest: _showContestPage,
                        onTapUser: _showUserPage,
                        onTapAllComments: _showCommentsPage,
                        fullScreen: _fullScreen,
                        showComments: widget.showComments)),
                onNotification: (ScrollNotification notification) =>
                    _handleScrollNotification(),
              ));
  }

  bool _handleScrollNotification() {
    setState(() {});
    return true;
  }

  void _handleFullScreenNotification(
      FullScreenNotification notification) async {
    await SystemChrome.setEnabledSystemUIOverlays(
        !_fullScreen ? <SystemUiOverlay>[] : SystemUiOverlay.values);
    setState(() {
      _fullScreen = !_fullScreen;
    });
    if (notification.callBack != null) notification.callBack();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
