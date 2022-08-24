import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:share/share.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/iphotoable.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/topic.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/pages/element_photos_page.dart';
import 'package:shuttertop/pages/password_confirm_page.dart';
import 'package:shuttertop/ui/contests/contest_list.dart';
import 'package:shuttertop/pages/contest_page.dart';
import 'package:shuttertop/pages/comments_page.dart';
import 'package:shuttertop/pages/image_fullscreen_page.dart';
import 'package:shuttertop/pages/photo_page.dart';
import 'package:shuttertop/pages/settings_page.dart';
import 'package:shuttertop/pages/user_page.dart';
import 'package:shuttertop/ui/widget/simple_page.dart';
import 'package:shuttertop/ui/users/avatar.dart';
import 'package:flutter/services.dart';

class WidgetUtils {
  static const MethodChannel platform =
      const MethodChannel('app.channel.shared.data');

  static FadeInImage netImage(String url, {double width, double height}) {
    return new FadeInImage.assetNetwork(
      placeholder: ImageAssets.transparentImage,
      image: url,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 300),
      fit: BoxFit.cover,
    );
  }

  static Future<Null> share(EntityBase element) async {
    if (element is Contest) {
      Share.share("https://shuttertop.com/contests/${element.slug}");
    } else {
      Share.share("https://shuttertop.com/photos/${element.slug}");
    }
  }

  static Widget buildTextComposer(
      BuildContext context, User user, bool isTyping) {
    return Material(
        elevation: 1.0,
        color: Colors.white30,
        child: Container(
          color: Colors.transparent,
          margin:
              EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0, top: 10.0),
          child: Row(children: <Widget>[
            Container(
                width: 36.0,
                height: 36.0,
                color: Colors.transparent,
                margin: EdgeInsets.only(right: 12.0),
                child: Avatar(
                  user.getImageUrl(ImageFormat.thumb),
                  backColor: Colors.grey,
                )),
            Expanded(
                child: Material(
              elevation: 0.5,
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: Container(
                  height: 38.0,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16.0, right: 5.0),
                  child: Row(
                      children: <Widget>[
                    Expanded(
                        child: TextField(
                            //autofocus: widget.autoFocus,
                            //controller: _textController,
                            /*onChanged: (String text) {
                              setState(() {
                                _isTyping = true;
                              });
                            },*/
                            //onSubmitted: _handleSubmitted,
                            decoration: InputDecoration.collapsed(
                                hintText: AppLocalizations.of(context)
                                    .sputaIlRospo))),
                    isTyping
                        ? InkWell(
                            child: Container(
                                padding: EdgeInsets.only(left: 12.0),
                                child: Icon(
                                  Icons.send,
                                  color: AppColors.brandPrimary,
                                  size: 24.0,
                                )),
                            onTap: () {})
                        : null
                  ].where((Widget e) => e != null).toList())),
            )),
          ]),
        ));
  }

  static Future<Null> showActivityObjectPage(
      BuildContext context, Activity activity) async {
    switch (activity.type) {
      case activityType.joined:
        await WidgetUtils.showPhotoPage(context, activity.photo,
            showComments: false);
        break;
      case activityType.contestCreated:
      case activityType.win:
      case activityType.followContest:
        await WidgetUtils.showContestPage(context, activity.contest,
            join: false, showComments: false);
        break;
      case activityType.commentedPhoto:
        await WidgetUtils.showCommentsPage(context, activity.photo,
            edit: false);
        break;
      case activityType.commentedContest:
        await WidgetUtils.showCommentsPage(context, activity.contest,
            edit: false);
        break;
      case activityType.vote:
        await WidgetUtils.showPhotoPage(context, activity.photo,
            showComments: false);
        break;
      case activityType.followUser:
        await WidgetUtils.showUserPage(context, activity.user);
        break;
      case activityType.signup:
      case activityType.firstAvatar:
        await WidgetUtils.showUserPage(context, activity.userTo);
        break;
      default:
        break;
    }
  }

  static Future<Null> showObjectPage(
      BuildContext context, dynamic element) async {
    if (element is Photo)
      await WidgetUtils.showPhotoPage(context, element, showComments: false);
    else if (element is Contest)
      await WidgetUtils.showContestPage(context, element,
          join: false, showComments: false);
    else if (element is User) await WidgetUtils.showUserPage(context, element);
  }

  static Future<Null> showPhotoPage(BuildContext context, Photo photo,
      {@required bool showComments, IPhotoable parentElement}) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: PhotoPage.routeName),
            builder: (BuildContext context) => new PhotoPage(
                  photo,
                  showComments: showComments,
                  parentElement: parentElement,
                )));
  }

  static Future<Null> showContestPage(BuildContext context, Contest contest,
      {@required bool join,
      @required bool showComments,
      bool initLoad = true}) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: ContestPage.routeName),
            builder: (BuildContext context) => new ContestPage(
                  contest,
                  join: join,
                  initLoad: initLoad,
                )));
  }

  static Future<Null> showImageFullScreenPage(
      BuildContext context, IPhotoable element) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: ImageFullScreenPage.routeName),
            builder: (BuildContext context) =>
                new ImageFullScreenPage(element)));
  }

  static Future<Null> showUserPage(BuildContext context, User user,
      {bool showComments = false}) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: UserPage.routeName),
            builder: (BuildContext context) =>
                new UserPage(user, showComments: showComments)));
  }

  static Future<Null> showCommentsPage(BuildContext context, EntityBase element,
      {@required bool edit, Topic topic}) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: CommentsPage.routeName),
            builder: (BuildContext context) => new CommentsPage(
                  element,
                  autoFocus: edit,
                  topic: topic,
                )));
  }

  static Future<Null> showSettingsPage(
    BuildContext context,
  ) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: SettingsPage.routeName),
          builder: (BuildContext context) => const SettingsPage(),
        ));
  }

  static Future<bool> showPasswordConfirmPage(BuildContext context,
      {String token, String email}) async {
    return await Navigator.push(
        context,
        new MaterialPageRoute<bool>(
          settings: const RouteSettings(name: PasswordConfirmPage.routeName),
          builder: (BuildContext context) => PasswordConfirmPage(
                token: token,
                email: email,
              ),
        ));
  }

  static Future<Null> showPhotoListPage(
      BuildContext context, User user, PhotosFetchType type) async {
    print("_photoPhotoListPage");
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: ElementPhotosPage.routeName),
            builder: (BuildContext context) =>
                new ElementPhotosPage(user, type: type)));
  }

  static Future<Null> showContestsCreatedPage(
      BuildContext context, User user) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: ContestList.routeName),
          builder: (BuildContext context) => new SimplePage(
                user.name,
                new ContestList(
                  user: user,
                  onTap: (Contest contest, {bool join}) =>
                      WidgetUtils.showContestPage(context, contest,
                          join: false, showComments: false),
                ),
                subtitle: AppLocalizations.of(context).contestCreati,
              ),
        ));
  }

  static Future<Null> showContestsFinishedPage(BuildContext context) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: ContestList.routeName),
          builder: (BuildContext context) => new SimplePage(
                "Contest terminati",
                new ContestList(
                  inProgress: false,
                  onTap: (Contest contest, {bool join}) =>
                      WidgetUtils.showContestPage(context, contest,
                          join: false, showComments: false),
                ),
              ),
        ));
  }

  static Future<Null> showContestsTopPage(BuildContext context) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: ContestList.routeName),
          builder: (BuildContext context) => new SimplePage(
                "Contest migliori",
                new ContestList(
                  order: ListOrder.top,
                  onTap: (Contest contest, {bool join}) =>
                      WidgetUtils.showContestPage(context, contest,
                          join: false, showComments: false),
                ),
              ),
        ));
  }

  static Future<Null> showContestsNewsPage(BuildContext context) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: ContestList.routeName),
          builder: (BuildContext context) => new SimplePage(
                "Contest recenti",
                new ContestList(
                  order: ListOrder.news,
                  onTap: (Contest contest, {bool join}) =>
                      WidgetUtils.showContestPage(context, contest,
                          join: false, showComments: false),
                ),
              ),
        ));
  }

  static void getImage(BuildContext context, String title, Function callBack,
      [String labelLoading]) async {
    final ImageSource source = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new Text(title),
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: _getImageOption(
                          context,
                          OMIcons.cameraAlt,
                          AppLocalizations.of(context).scattaUnaFoto,
                          () {
                            Navigator.pop(context, ImageSource.camera);
                          },
                        )),
                    _getImageOption(
                      context,
                      OMIcons.photoLibrary,
                      AppLocalizations.of(context).apriLaGalleria,
                      () {
                        Navigator.pop(context, ImageSource.gallery);
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        });
    if (source != null) {
      try {
        final File fileName = await ImagePicker.pickImage(
            source: source, maxWidth: 1200.0, maxHeight: 1200.0);
        if (fileName != null) {
          await new Future<Null>.delayed(new Duration(milliseconds: 100));
          print("before loading");
          onLoading(context, labelLoading);

          callBack(fileName);
        }
      } catch (error) {
        callBack(null, error);
      }
    }
  }

  static Widget _getImageOption(
      BuildContext context, IconData icon, String text, Function onTap) {
    return Material(
        child: InkWell(
            splashColor: Colors.grey[400],
            onTap: onTap,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 32.0,
                      color: Colors.grey[800],
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          text,
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              fontFamily: "Raleway"),
                        ))
                  ],
                ))));
  }

  static void onLoading(BuildContext context, [String labelLoading]) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new Dialog(
            child: new Container(
                height: 300,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24.0),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    WidgetUtils.spinLoader(),
                    new Container(
                      alignment: Alignment.center,
                      child: Text(
                        labelLoading ??
                            AppLocalizations.of(context).caricamento,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                      ),
                      padding: const EdgeInsets.only(top: 20.0),
                    ),
                  ],
                )),
          );
        });
  }

  static Widget spinLoader() {
    return CircularProgressIndicator();
  }

  static RadialGradient contestGradient() {
    return new RadialGradient(
      colors: [Colors.blueGrey[800], Colors.blueGrey[900]],
      radius: 1.0,
      stops: <double>[
        0.0,
        0.8,
      ],
    );
  }

  static LinearGradient categoryGradient(Category category) {
    return new LinearGradient(
        colors: category.colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter);
  }

  static LinearGradient contestGradient1(Contest contest) {
    return new LinearGradient(
        colors: contest.category.colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter);
  }

  /*static void checkSharedImage(BuildContext context) async {
    final dynamic notification = await platform.invokeMethod("getNotification");
    print("NOTIFICATION!!!! $notification");
    if (notification != null) {
      FCM.navigateTo(context, notification);
    }

    print("checkSharedImage");
    if (shuttertop.sharedImage != null) {
      await Navigator.push(
          context,
          new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: SharedPage.routeName),
            builder: (BuildContext context) =>
                new SharedPage(shuttertop.sharedImage),
          ));
      shuttertop.sharedImage = null;
    }
  }*/
}
