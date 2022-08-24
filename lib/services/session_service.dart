import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/exceptions.dart';
import 'package:shuttertop/models/info.dart';
import 'package:shuttertop/models/session.dart';
import 'package:shuttertop/services/base_service.dart';

class SessionService extends BaseService implements SessionRepository {
  @override
  String get url => "";
  static const String _devicesUrl = "/devices";
  static const String _loginUrl = "/auth/identity/callback";
  static const String _getInfo = "/devices/get_info";
  static const String _recoveryUrl = "/auth/password_recovery";
  static const String _registrationConfirm = "/registration_confirm";
  static const String _anotherLife = "/another_life";
  static const String _anotherLifeConfirm = "/another_life_confirm";
  static const String _changePassword = "/auth/change_password";

  Session get currentSession => shuttertop.currentSession;

  set currentSession(Session session) => shuttertop.currentSession = session;

  @override
  Future<ResponseApi<Session>> signIn(String email, String password) async {
    return await handleSignInResponse(await httpPost(
        <String, dynamic>{'email': email, 'password': password},
        postUrl: "${shuttertop.siteUrl}$_loginUrl"));
  }

  @override
  Future<ResponseApi<Session>> registrationConfirm(
      String email, String token) async {
    return await handleSignInResponse(await httpPost(
        <String, dynamic>{'email': email, 'token': token},
        postUrl: "${shuttertop.siteUrl}$_registrationConfirm"));
  }

  @override
  Future<ResponseApi<Session>> anotherLife(String email, String token) async {
    return await handleSignInResponse(await httpPost(
        <String, dynamic>{'email': email, 'token': token},
        postUrl: "${shuttertop.siteUrl}$_anotherLife"));
  }

  @override
  Future<bool> anotherLifeConfirm(
      String email, String token, String password) async {
    final Map<String, dynamic> ret = await httpPost(
        <String, dynamic>{'email': email, 'token': token, 'password': password},
        postUrl: "${shuttertop.siteUrl}$_anotherLifeConfirm");
    return ret["success"];
  }

  @override
  Future<bool> changePassword(String password, String oldPassword) async {
    final Map<String, dynamic> ret = await httpPost(
        <String, dynamic>{'password': password, 'old_password': oldPassword},
        postUrl: "${shuttertop.siteUrl}$_changePassword");
    return ret["success"];
  }

  @override
  Future<Session> signInGoogle() async {
    print("Google Sign In");
    final String accessToken = await getGoogleToken();
    if (accessToken != null) return _signInSocial("google", accessToken);

    return null;
  }

  Future<String> getGoogleToken() async {
    try {
      final GoogleSignIn googleSignIn =
      new GoogleSignIn(scopes: <String>['email']);
      final GoogleSignInAccount account = await googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication value = await account.authentication;
        print("google sign in authentication: ${value.accessToken}");
        return value.accessToken;
      }
    } catch(ex) {
      print("getGoogleToken: google sign in authentication: ${ex.toString()}");
      rethrow;
    }
    return null;
  }

  @override
  Future<Session> signInFacebook() async {
    try {
      print("Facebook Sign In");
      final String accessToken = await getFacebookToken();
      if (accessToken != null) return _signInSocial("facebook", accessToken);
    } catch (error) {
      print("errore!!!!");
      print(error);
    }
    return null;
  }

  Future<String> getFacebookToken() async {
    try {
      print("Facebook Sign In");

      final FacebookLogin facebookLogin = new FacebookLogin();
      final FacebookLoginResult result =
          await facebookLogin.logInWithReadPermissions(<String>['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          print("Facebook Sign In token ${result.accessToken.token}");
          return result.accessToken.token;
          break;
        case FacebookLoginStatus.cancelledByUser:
          //_showCancelledMessage();
          break;
        case FacebookLoginStatus.error:
          //_showErrorOnUI(result.errorMessage);
          break;
      }
    } catch (error) {
      print("errore!!!!");
      print(error);
    }
    return null;
  }

  @override
  Future<Session> checkSession() async {
    final String _currentSessionUrl = "${shuttertop.siteUrl}/current_session";
    if (currentSession != null)
      return currentSession;
    else {
      final String token = await getStoredToken();
      if (token != "") {
        try {
          shuttertop.currentSession = new Session(token: token);
          final ResponseApi<Session> ret = await handleSignInResponse(
              await httpGet(getUrl: _currentSessionUrl));
          if (ret.success)
            return ret.element;
          else
            throw new Exception();
        } catch (e) {
          print(
              "ERRORE checkSession: ${e.hashCode} - $e - $_currentSessionUrl");
          removeStoredToken();
        }
      } else {}
    }
    return null;
  }

  @override
  Future<Info> getInfo() async {
    try {
      final dynamic ret =
          await httpGet(getUrl: "${shuttertop.siteUrl}$_getInfo");
      return Info.fromMap(ret);
    } catch (e) {
      if (e is ConnException) rethrow;
      print("ERRORE getInfo: ${e.hashCode} - $e - $_getInfo");
    }
    return null;
  }

  Future<String> getStoredToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken') ?? "";
  }

  Future<Null> removeStoredToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<Null> removeStoredFireBaseToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("fcmToken");
  }

  Future<Session> _signInSocial(String provider, String token) async {
    try {
      final String url = "${shuttertop.siteUrl}/auth/social/$provider/$token";
      final ResponseApi<Session> ret = await handleSignInResponse(
          await httpPost(<String, dynamic>{}, postUrl: url));
      if (ret.success)
        return ret.element;
      else
        throw new Exception();
    } catch (e) {
      print("_signInSocial errore!! $e");
      return null;
    }
  }

  Future<ResponseApi<Session>> handleSignInResponse(
      Map<String, dynamic> sessionContainer) async {
    try {
      final ResponseApi<Session> ret =
          new ResponseApi<Session>(!sessionContainer.containsKey("error"));
      if (ret.success) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userToken', sessionContainer["jwt"]);

        shuttertop.currentSession = new Session.fromMap(sessionContainer);
        ret.element = shuttertop.currentSession;
      } else
        ret.errors = sessionContainer;
      return ret;
    } catch (e) {
      print("ERRORE handleSignInResponse $e - $sessionContainer");
      rethrow;
    }
  }

  @override
  Future<String> addToken(PlatformApp platform) async {
    print("before notifies token");
    try {
      final String token = await getFireBaseToken();
      print("after notifies token $token");
      shuttertop.firebaseMessaging.subscribeToTopic("contest_created");
      final Map<String, dynamic> resp2 = await httpPost(<String, dynamic>{
        'device': <String, dynamic>{
          "platform": platform == PlatformApp.android ? 'android' : 'ios',
          "token": token,
        }
      }, postUrl: "${shuttertop.siteUrl}$_devicesUrl");
      print("device add: $resp2");
      storeFireBaseToken(token);
      return token;
    } catch (e) {
      print("errore token!! $e");
    }
    return null;
  }

  @override
  Future<bool> removeToken() async {
    print("before notifies token");
    try {
      final String token = await getFireBaseToken();
      print("after notifies token $token");
      final Map<String, dynamic> resp2 = await httpDelete(
          id: token, deleteUrl: "${shuttertop.siteUrl}$_devicesUrl");
      print("device add: $resp2");
      removeStoredFireBaseToken();
      return true;
    } catch (e) {
      print("errore token!! $e");
      return false;
    }
  }

  @override
  Future<bool> recovery(String email) async {
    print("recovery");
    return (await httpPost(<String, dynamic>{'email': email},
        postUrl: "${shuttertop.siteUrl}$_recoveryUrl"))["success"];
  }

  @override
  Future<bool> logout() async {
    try {
      removeToken();
      await httpDelete(deleteUrl: "${shuttertop.siteUrl}/logout");
      removeStoredToken();
      shuttertop.link = null;
      currentSession = null;
    } catch (error) {
      print("ERRORE LOGOUT: $error");
    }
    return true;
  }

  Future<String> getFireBaseToken() async {
    return await shuttertop.firebaseMessaging.getToken();
  }

  Future<Null> storeFireBaseToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fcmToken', token);
  }
}
