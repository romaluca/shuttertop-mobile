import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shuttertop/misc/secrets.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/activity.dart';
import 'package:shuttertop/models/comment.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/models/entity_base.dart';
import 'package:shuttertop/models/photo.dart';
import 'package:shuttertop/models/session.dart';
import 'package:shuttertop/misc/s3.dart';
import 'package:shuttertop/models/topic.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/activity_service.dart';
import 'package:shuttertop/services/comment_service.dart';
import 'package:shuttertop/services/contest_service.dart';
import 'package:shuttertop/services/photo_service.dart';
import 'package:shuttertop/services/session_service.dart';
import 'package:sentry/sentry.dart';
import 'package:shuttertop/services/topic_service.dart';
import 'package:shuttertop/services/user_service.dart';
import 'package:firebase_admob/firebase_admob.dart';

ShuttertopApp shuttertop = new ShuttertopApp();

enum PlatformApp { iOs, android, web }

enum ModeRun { debug, production }

class ShuttertopApp {
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final SentryClient sentry = new SentryClient(dsn: Secrets.SentryDNS);

  ModeRun mode;
  PlatformApp platform;
  EventBus eventBus = new EventBus();
  Uri link;
  Session currentSession;

  static final ShuttertopApp _singleton = new ShuttertopApp._internal();

  EntityBase currentEntityComments;

  factory ShuttertopApp() {
    return _singleton;
  }

  ShuttertopApp._internal();

  String get hostName {
    if (mode == ModeRun.production)
      return "shuttertop.com";
    else if (platform == PlatformApp.iOs)
      return "arcimboldo:8080"; //return "localhost:8080";
    else
      return "10.0.2.2:8080";
  }

  String get siteUrl {
    if (mode == ModeRun.production)
      return "https://$hostName/api";
    else
      return "http://$hostName/api";
  }

  String get apiKey {
    if (mode == ModeRun.debug)
      return Secrets.ApiKeyDev;
    else
      return Secrets.ApiKeyProd;
  }

  //PhoenixSocket _socket;

  //Uri linkToOpen;
  //File sharedImage;

  void init({ModeRun mode, PlatformApp platform}) async {
    this.mode = mode;
    this.platform = platform;

    FirebaseAdMob.instance.initialize(
        appId: mode == ModeRun.debug
            ? FirebaseAdMob.testAppId
            : Secrets.AdMobAppId);
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.dumpErrorToConsole(details);
    };
  }

  /*@override
  Future<PhoenixSocket> get socket async {
    try {
      if (_socket == null) {
        print("SOCKET NEW: $socketUrl");
        _socket = new PhoenixSocket(socketUrl, params: <String, String>{
          "token": currentSession.token,
          "api_key": apiKey
        });
      }

      if (!_socket.isConnected()) {
        print("SOCKET connecting");
        await _socket.connect();
        print("SOCKET is connected: ${_socket.isConnected()}");
        assert(_socket.isConnected());
      }
      return _socket;
    } catch (e) {
      print("ERRORE socket $e");
      rethrow;
    }
  }*/

  S3 get getS3 => new S3(Secrets.S3AccessKeyId, Secrets.S3secretAccessKey,
      Utils.S3host, "img.shuttertop.com");

  String get token => currentSession?.token;

  Future<Null> disconnect([bool onlySocket = false]) async {
    try {
      //if (_socket != null) _socket.disconnect();
      //if (!onlySocket) _socket = null;
    } catch (error) {
      print("ERROR disconnect: $error");
    }
    if (!onlySocket) {
      await sessionRepository.logout();
      currentSession = null;
      //linkToOpen = null;
    }
  }

  int get currentUserId => currentSession?.user?.id;

  SessionRepository get sessionRepository {
    return new SessionService();
  }

  ActivityRepository get activityRepository {
    return new ActivityService();
  }

  ContestRepository get contestRepository {
    return new ContestService();
  }

  CommentRepository get commentRepository {
    return new CommentService();
  }

  PhotoRepository get photoRepository {
    return new PhotoService();
  }

  UserRepository get userRepository {
    return new UserService();
  }

  TopicRepository get topicRepository {
    return new TopicService();
  }
}
