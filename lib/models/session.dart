import 'dart:async';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/info.dart';
import 'package:shuttertop/models/user.dart';
import 'package:shuttertop/services/base_service.dart';

class Session {
  Session({this.token, this.user});

  Session.fromMap(Map<String, dynamic> map)
      : token = map['jwt'],
        notifyCount = map['notify_count'] ?? 0,
        notifyMessageCount = map['notify_message_count'] ?? 0,
        notifiesEnabled = map['notifies_enabled'] ?? true,
        notifyContestCreated = map['notifies_contest_created'] ?? 0,
        user = new User.fromMap(map['user']);

  final String token;
  final User user;
  int notifyCount;
  int notifyMessageCount;
  bool notifiesEnabled;
  int notifyContestCreated;
}

abstract class SessionRepository {
  Future<ResponseApi<Session>> signIn(String email, String password);
  Future<Session> signInGoogle();
  Future<Session> signInFacebook();
  Future<Session> checkSession();
  Future<bool> recovery(String email);
  Future<String> addToken(PlatformApp platform);
  Future<bool> removeToken();
  Future<bool> logout();
  Future<Info> getInfo();
  Future<ResponseApi<Session>> registrationConfirm(String email, String token);
  Future<ResponseApi<Session>> anotherLife(String email, String token);
  Future<bool> anotherLifeConfirm(String email, String token, String password);
  Future<bool> changePassword(String password, String oldPassword);
}
