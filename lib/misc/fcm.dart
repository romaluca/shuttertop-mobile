import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCM {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  static void getToken(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('noFcm') == null) {
      //if (prefs.getString('fcmToken') == null)
      //  prefs.setString('fcmToken',
      //      await shuttertop.sessionRepository.addToken());
      print("---------------FIREBASE!!:  _getToken()");
      shuttertop.firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print("----------FIREBASE!!:  onMessage: $message");
          showNotification(message);
          return null;
        },
        onLaunch: (Map<String, dynamic> message) {
          print("----------FIREBASE!! onLaunch:  $message");
          navigateTo(context, message);
          return null;
        },
        onResume: (Map<String, dynamic> message) {
          print("----------FIREBASE!!: onResume  $message");
          navigateTo(context, message);
          return null;
        },
      );
      shuttertop.firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: false, badge: false, alert: false));
      shuttertop.firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });

      final AndroidInitializationSettings initializationSettingsAndroid =
          new AndroidInitializationSettings('@drawable/ic_stat_camera');
      final IOSInitializationSettings initializationSettingsIOS =
          new IOSInitializationSettings();
      final InitializationSettings initializationSettings =
          new InitializationSettings(
              initializationSettingsAndroid, initializationSettingsIOS);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
          const JsonCodec json = const JsonCodec();
          navigateTo(context, json.decode(payload));
        }
      });

      await shuttertop.sessionRepository.addToken(shuttertop.platform);
    }
  }

  static void showNotification(Map<String, dynamic> msg) async {
    final Map<dynamic, dynamic> data =
        shuttertop.platform == PlatformApp.android ? msg["data"] : msg;
    final activityType t = activityType.values[int.parse(data["type"])];

    checkCommentNotification(data, t);
    if (shuttertop.currentEntityComments != null) {
      if ((t == activityType.commentedContest &&
              shuttertop.currentEntityComments is Contest) ||
          (t == activityType.commentedPhoto &&
              shuttertop.currentEntityComments is Photo) ||
          (t == activityType.commentedUser &&
              shuttertop.currentEntityComments is User)) return;
    }
    final File file = await DefaultCacheManager().getSingleFile(
        User.getImageUrlFromUpload(data["user_upload"], ImageFormat.thumb));

    final AndroidNotificationDetails android = new AndroidNotificationDetails(
        'sdffds dsffds', "CHANNLE NAME", "channelDescription",
        largeIcon: file.path,
        color: AppColors.brandPrimary,
        largeIconBitmapSource: BitmapSource.FilePath);
    final IOSNotificationDetails iOS = new IOSNotificationDetails();
    final NotificationDetails platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, data["title"] ?? "Shuttertop", data["body"], platform,
        payload: json.encode(data));
  }

  static void checkCommentNotification(
      Map<dynamic, dynamic> data, activityType t) {
    if (!isCommentType(t)) return;
    const JsonCodec json = const JsonCodec();
    final Map<dynamic, dynamic> comment = json.decode(data["comment"]);
    if (t == activityType.commentedContest)
      shuttertop.eventBus.fire(
          CommentEvent(Comment.fromMap(comment), "c_${comment["contest_id"]}"));
    if (t == activityType.commentedPhoto)
      shuttertop.eventBus.fire(
          CommentEvent(Comment.fromMap(comment), "p_${comment["photo_id"]}"));
    if (t == activityType.commentedUser)
      shuttertop.eventBus.fire(
          CommentEvent(Comment.fromMap(comment), "u_${comment["user"]["id"]}"));
  }

  static bool isCommentType(activityType t) {
    return t == activityType.commentedContest ||
        t == activityType.commentedPhoto ||
        t == activityType.commentedUser;
  }

  static Future<Null> navigateTo(
      BuildContext context, Map<dynamic, dynamic> message) async {
    if (message["type"] == null) return;
    await new Future<dynamic>.delayed(new Duration(milliseconds: 100));
    final activityType t = activityType.values[int.parse(message["type"])];
    switch (t) {
      case activityType.followContest:
      case activityType.win:
      case activityType.contestCreated:
        final Contest contest = new Contest(
            id: int.parse(message["contest_id"]),
            slug: message["contest_slug"],
            user: new User(id: int.parse(message["contest_user_id"])));
        WidgetUtils.showContestPage(context, contest,
            join: false, showComments: false);
        break;
      case activityType.joined:
      case activityType.followPhoto:
      case activityType.vote:
        WidgetUtils.showPhotoPage(
            context,
            new Photo(
                id: int.parse(message["photo_id"]),
                slug: message["photo_slug"],
                user: new User(id: int.parse(message["photo_user_id"]))),
            showComments: false);
        break;
      case activityType.followUser:
        print(
            "NOTIFY followUser user_id: ${message["user_id"]} user_slug: ${message["user_slug"]}");
        WidgetUtils.showUserPage(
            context,
            new User(
                id: int.parse(message["user_id"]), slug: message["user_slug"]));
        break;
      case activityType.commentedUser:
        WidgetUtils.showUserPage(
            context, new User.fromMap(json.decode(message["comment"])["user"]),
            showComments: true);
        break;
      case activityType.commentedPhoto:
        WidgetUtils.showPhotoPage(
            context,
            new Photo(
                id: int.parse(message["photo_id"]),
                slug: message["photo_slug"],
                user: new User(id: int.parse(message["photo_user_id"]))),
            showComments: true);
        break;
      case activityType.commentedContest:
        WidgetUtils.showContestPage(
            context,
            new Contest(
                id: int.parse(message["contest_id"]),
                slug: message["contest_slug"],
                user: new User(id: int.parse(message["contest_user_id"]))),
            showComments: true,
            join: false);
        break;
      default:
    }
  }
}
