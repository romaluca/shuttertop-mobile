import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/info.dart';
import 'package:shuttertop/models/session.dart';
import 'package:shuttertop/services/base_service.dart';
import 'package:shuttertop/ui/widget/oval_top_border_clipper.dart';
import 'package:shuttertop/pages/sign_in_page.dart';
import 'package:shuttertop/pages/main_page.dart';
import 'package:shuttertop/pages/signup_page.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shuttertop/models/exceptions.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

  static const String routeName = '/';

  @override
  State createState() => new _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isChecking;
  bool _isLoading = false;
  bool _isMinimumTimeExpired = false;
  bool _isUserLogged = false;
  double _height;

  AnimationController controllerLogo;
  Animation animationCurve;
  Animation<double> animationLogo;
  Animation<double> animationLogoPos;
  Animation<double> animationForm;

  Animation<Color> animationColor2;

  Future<void> delayedChecker;

  @override
  void initState() {
    super.initState();
    _isChecking = true;
    try {
      new Future<void>.delayed(const Duration(milliseconds: 1500), () {
        _height = MediaQuery.of(context).size.height;
        initUI();
      });
      checkSession();
      delayedChecker = new Future<void>.delayed(
          const Duration(seconds: 2),
          () => setState(() {
                _isMinimumTimeExpired = true;
                if (!_isUserLogged) controllerLogo.forward();
                _checkUri().then((Session session) {
                  if (_isUserLogged) _onUserLogged();
                });
              }));
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  void initUI() {
    try {
      controllerLogo = new AnimationController(
          duration: const Duration(milliseconds: 500), vsync: this);
      animationCurve =
          CurvedAnimation(parent: controllerLogo, curve: Curves.easeOut);
      animationLogo = Tween<double>(begin: 200, end: 80).animate(animationCurve)
        ..addListener(() {
          setState(() {
            // the state that has changed here is the animation object’s value
          });
        });
      animationColor2 = ColorTween(
              begin: Colors.grey.withOpacity(0.35), end: Colors.grey[800])
          .animate(animationCurve)
            ..addListener(() {
              setState(() {
                // the state that has changed here is the animation object’s value
              });
            });
      final double from = (_height / 2) - 100;
      print("frommmmm $from");
      animationLogoPos =
          Tween<double>(begin: from, end: 467).animate(animationCurve)
            ..addListener(() {
              setState(() {
                // the state that has changed here is the animation object’s value
              });
            });
      animationForm = Tween<double>(begin: -360, end: 0).animate(animationCurve)
        ..addListener(() {
          setState(() {
            // the state that has changed here is the animation object’s value
          });
        });
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  @override
  void dispose() {
    controllerLogo.dispose();
    super.dispose();
  }

  Future<Null> checkSession([int retry = 0]) async {
    try {
      final PackageInfo infoApp = await PackageInfo.fromPlatform();
      final Info info = await shuttertop.sessionRepository.getInfo();
      print("infoooooooo $info");
      bool versionOK = false;
      if (Platform.isAndroid) {
        print(
            "AndroidVersion: ${infoApp.buildNumber} - MinAndroidVersion: ${info.minAndroidVersion}");
        versionOK = int.parse(infoApp.buildNumber) >= info.minAndroidVersion;
      } else {
        print(
            "IOSVersion: ${infoApp.buildNumber} - MinIosVersion: ${info.minIosVersion}");
        versionOK =
            int.parse(infoApp.buildNumber) >= int.parse(info.minIosVersion);
      }
      if (versionOK) {
        if (await shuttertop.sessionRepository.checkSession() != null)
          _onUserLogged();
        else
          _onSessionChecked();
      } else
        showUpdateDialog();
    } catch (err) {
      if (err is ConnException) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 4),
            content: Text(AppLocalizations.of(context)
                .nonRiescoAConnettermiAllaReteCiRiprovoPerLaVolta(retry + 1))));
        new Future<void>.delayed(
            const Duration(seconds: 5), () => checkSession(retry + 1));
      }
      print("ERRORE checkSession $err ${err.runtimeType}");
    }
  }

  Future<Session> _checkUri() async {
    if (shuttertop.link == null) return null;
    final Uri uri = shuttertop.link;
    if (uri != null && uri.pathSegments.isNotEmpty) {
      print("uri pathSegments first: ${uri.pathSegments.first}");
      if (uri.pathSegments.first == "registration_confirm") {
        final String email = uri.queryParameters["email"];
        final String token = uri.queryParameters["token"];
        print("registration_confirm email: $email token: $token");
        final ResponseApi<Session> ret = await shuttertop.sessionRepository
            .registrationConfirm(email, token);
        if (ret.success)
          Navigator.of(context)
              .pushNamedAndRemoveUntil(MainPage.routeName, (_) => false);
        return ret.element;
      } else if (uri.pathSegments.first == "another_life") {
        final String email = uri.queryParameters["email"];
        final String token = uri.queryParameters["token"];
        print("another_life email: $email token: $token");

        final ResponseApi<Session> ret =
            await shuttertop.sessionRepository.anotherLife(email, token);
        if (ret.success) {
          shuttertop.link = Uri.parse(
              "https://shuttertop.com/another_life_confirm?email=$email&token=$token");
          Navigator.of(context)
              .pushNamedAndRemoveUntil(MainPage.routeName, (_) => false);
        }
        return ret.element;
      }
    }
    return null;
  }

  void showUpdateDialog() {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Shuttertop"),
            content: new Text(AppLocalizations.of(context)
                .perProseguireENecessarioAggiornaleLapp),
            actions: <Widget>[
              new FlatButton(
                  child:
                      Text(AppLocalizations.of(context).aggiorna.toUpperCase()),
                  onPressed: () async {
                    final String url = Platform.isAndroid
                        ? "https://play.google.com/store/apps/details?id=com.shuttertop.android"
                        : "https://itunes.apple.com/us/app/id1117941080?mt=8";
                    if (await canLaunch(url)) {
                      await launch(url,
                          forceSafariVC: false, forceWebView: false);
                    } else {
                      print("non posso aprire una cippa");
                    }
                  }),
            ],
          );
        });
  }

  void signInFacebook() {
    _onLoading();
    shuttertop.sessionRepository.signInFacebook().then((Session session) {
      if (session != null)
        _onUserLogged();
      else
        _onError();
    });
  }

  void signInGoogle() async {
    _onLoading();
    try {
      final Session session = await shuttertop.sessionRepository.signInGoogle();
      if (session != null) _onUserLogged();
      //else
      //  _onError("cazzarola");
    } catch (e) {
      _onError("e $e");
    }
  }

  void _onSessionChecked() {
    setState(() {
      _isChecking = false;
    });
  }

  void _onUserLogged() {
    print("isLoading $_isLoading");
    if (_isMinimumTimeExpired)
      Navigator.of(context).pushNamedAndRemoveUntil(
          MainPage.routeName, (Route<dynamic> route) => false);
    else
      _isUserLogged = true;
  }

  void _onLoading() {
    _isLoading = true;
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                height: 94.0,
                padding: EdgeInsets.all(24.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    WidgetUtils.spinLoader(),
                    Container(
                      child: Text(
                        AppLocalizations.of(context).caricamento,
                        // ignore: conflicting_dart_import
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Raleway",
                            color: Colors.grey[500]),
                      ),
                      padding: EdgeInsets.only(left: 20.0),
                    ),
                  ],
                )),
          );
        });
    //Navigator.of(context).pop();
  }

  void _showSignInPage() async {
    final dynamic ret = await Navigator.push(
        context,
        MaterialPageRoute<bool>(
          settings: RouteSettings(name: SignInPage.routeName),
          builder: (BuildContext context) => SignInPage(),
        ));
    if (ret != null && ret) _onUserLogged();
  }

  void _showSignUpPage() {
    Navigator.push(
        context,
        MaterialPageRoute<Null>(
          settings: RouteSettings(name: SignUpPage.routeName),
          builder: (BuildContext context) => SignUpPage(),
        ));
  }

  void _onError([dynamic error]) {
    print("welcomeView onError");
    Navigator.of(context).pop();
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errore(error))));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white, key: _scaffoldKey, body: _buildBody());
  }

  Widget _buildBody() {
    final Color borderColor = Colors.black54;
    final Color iconColor = Colors.grey;
    final Widget svg = new SvgPicture.asset(
      'assets/images/logo.svg',
    );
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          bottom: _height == null ? null : animationLogoPos.value,
          left: 0,
          right: 0,
          child: Container(
              alignment: Alignment.center,
              height: _height == null ? 200 : animationLogo.value,
              width: _height == null ? 200 : animationLogo.value,
              child: svg),
        ),
        Positioned(
            bottom: _height == null ? -360 : animationForm.value,
            left: 0,
            right: 0,
            child: new Container(
                height: 467.0,
                //padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        alignment: FractionalOffset.center,
                        child: Text("Shuttertop",
                            style: TextStyle(
                                color: _height == null
                                    ? Colors.grey.withOpacity(0.35)
                                    : animationColor2.value,
                                fontFamily: "Raleway",
                                fontWeight: FontWeight.bold,
                                fontSize: 32.0)),

                        /* Icon(Ionicons.logoShuttertop,
                  size: 40.0, color: Color(0xFFFFFFFF)),*/
                      ),
                      Container(
                          padding: EdgeInsets.only(bottom: 24.0, top: 16.0),
                          alignment: Alignment.center,
                          child: _isMinimumTimeExpired
                              ? Text(
                                  AppLocalizations.of(context)
                                      .contestFotograficiImprovvisati,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Raleway",
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                )
                              : Shimmer.fromColors(
                                  baseColor: Colors.grey.withOpacity(0.4),
                                  highlightColor: Colors.grey[300],
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .scrostaLaTuaImmaginazione,
                                    style: TextStyle(
                                        fontFamily: "Raleway",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                        color: Colors.white),
                                  ))),
                      ClipOval(
                          clipper: OvalTopBorderClipper(),
                          child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFFF512F),
                                    const Color(0xFFDD2476)
                                  ], // whitish to gray
                                  tileMode: TileMode
                                      .repeated, // repeats the gradient over the canvas
                                ),
                              ),
                              padding: EdgeInsets.only(
                                  left: 48, right: 48, bottom: 24, top: 70),
                              child: Column(children: <Widget>[
                                InkWell(
                                    //splashColor: Colors.black87,
                                    onTap: () {
                                      _showSignUpPage();
                                    },
                                    child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15.0),
                                        alignment: FractionalOffset.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                              width: 1.0,
                                              color: Colors.white30),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .createAccountShuttertop,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontFamily: "Raleway",
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontWeight: FontWeight.w600),
                                        ))),
                                Container(
                                    margin: EdgeInsets.only(top: 16.0),
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            //splashColor: Colors.black87,
                                            onTap: () {
                                              _showSignInPage();
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 15.0),
                                                alignment:
                                                    FractionalOffset.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  border: Border.all(
                                                      width: 1.0,
                                                      color: Colors.white30),
                                                  //color: AppColors.brandPrimary,
                                                  //color: Colors.grey[200]
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .accediConLaMail,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      fontFamily: "Raleway",
                                                      fontSize: 15.0,
                                                      //color: Colors.black.withOpacity(0.7),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ))))),
                                Container(
                                    padding: EdgeInsets.only(
                                        bottom: 24.0, top: 24.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppLocalizations.of(context).continuaCon,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: "Raleway",
                                          fontSize: 15.0,
                                          color: Colors.white.withOpacity(0.9)),
                                    )),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                        child: Container(
                                            padding:
                                                EdgeInsets.only(right: 12.0),
                                            child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                    // splashColor: Colors.black87,
                                                    onTap: signInGoogle,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 11.0,
                                                              horizontal: 16.0),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        border: Border.all(
                                                            width: 1.0,
                                                            color:
                                                                Colors.white30),
                                                      ),
                                                      child: Container(
                                                        child: Icon(
                                                          FontAwesomeIcons
                                                              .google,
                                                          size: 22,
                                                          color: Colors.white
                                                              .withOpacity(0.8),
                                                        ),
                                                      ),
                                                    ))))),
                                    Expanded(
                                        child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                                //splashColor: Colors.black87,
                                                onTap: signInFacebook,
                                                child: Container(
                                                  padding: EdgeInsets.all(12.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.white30),
                                                  ),
                                                  child: Container(
                                                    child: Icon(
                                                      FontAwesomeIcons
                                                          .facebookF,
                                                      size: 20,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                )))),
                                  ],
                                ),
                              ]))),
                    ])
                // Set background
                //decoration: BoxDecoration(color: Colors.white)
                ))
      ],
    );
  }
}
