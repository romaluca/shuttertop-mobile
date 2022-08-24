import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/fcm.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/models/contest.dart';
import 'package:shuttertop/pages/contest_create_page.dart';
import 'package:shuttertop/pages/contests_page.dart';
import 'package:shuttertop/pages/shared_page.dart';
import 'package:shuttertop/ui/widget/main_drawer.dart';
import 'package:shuttertop/pages/news_page.dart';
import 'package:shuttertop/pages/notifies_page.dart';
import 'package:shuttertop/pages/users_page.dart';
import 'package:shuttertop/ui/widget/icon_badge.dart';
import 'package:shuttertop/ui/widget/widget_utils.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  static const String routeName = '/main';

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final GlobalKey<NewsPageState> keyScore = GlobalKey<NewsPageState>();
  static final GlobalKey<NewsPageState> keyWins = GlobalKey<NewsPageState>();
  static final GlobalKey<NewsPageState> keyInProgress =
      GlobalKey<NewsPageState>();

  PageController _pageController;
  int _page = 0;
  bool notifiesEnabled = false;
  ContestsPage pageContests;
  UsersPage pageUsers;
  NewsPage pageNews;
  /*
  UserPage pageProfile = new UserPage(
    shuttertop.currentUser.user,
    withBackButton: false,
  );*/
  NotifiesPage pageNotifies;
  List<Widget> pages;
  Widget currentPage;

  List<List<dynamic>> targets = <List<dynamic>>[
    <dynamic>[keyWins, "Qui ci sono le tue vincite"],
    <dynamic>[keyScore, "Invece qua il punteggio"],
    <dynamic>[keyInProgress, "Le tue foto in gara"],
  ];

  Offset _center;
  double _radius = 50.0;
  bool _enabled = false;
  Widget _description;

  int _index = 0;

  void spotlight(int index) {
    try {
      if (index >= targets.length) {
        index = 0;
        setState(() {
          _enabled = false;
        });
        return;
      }
      final Rect target = Spotlight.getRectFromKey(targets[index][0]);
      setState(() {
        _enabled = true;
        _center = Offset(target.center.dx, target.center.dy);
        _radius = Spotlight.calcRadius(target);
        _description = Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          alignment: Alignment.center,
          child: Text(
            targets[index][1],
            style: ThemeData.dark()
                .textTheme
                .display4
                .copyWith(color: Colors.white),
          ),
        );
      });
    } catch (ex) {
      print("ERRORE!!: spotlight: $ex");
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      WidgetsBinding.instance.addObserver(this);
      _connect();
      _pageController = PageController();
      pageNotifies = NotifiesPage(shuttertop.currentSession.user,
          openDrawer: () => _scaffoldKey.currentState.openDrawer());
      pageContests = ContestsPage(
          openDrawer: () => _scaffoldKey.currentState.openDrawer());
      pageUsers =
          UsersPage(openDrawer: () => _scaffoldKey.currentState.openDrawer());
      pageNews = NewsPage(
          openDrawer: () => _scaffoldKey.currentState.openDrawer(),
          openContests: () => navigationTapped(1),
          keyWins: keyWins,
          keyInProgress: keyInProgress,
          keyScore: keyScore);
      pages = <Widget>[
        pageNews,
        pageContests,
        pageUsers,
        pageNotifies
      ]; //pageProfile];

      currentPage = pageNews;
      FCM.getToken(context);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.white));
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }

    shuttertop.eventBus
        .on<ImageSharedEvent>()
        .listen((ImageSharedEvent event) async {
      print("ImageSharedEvent!!");
      await Navigator.push(
          context,
          new MaterialPageRoute<Null>(
            settings: const RouteSettings(name: SharedPage.routeName),
            builder: (BuildContext context) => new SharedPage(event.image),
          ));
    });
    _checkUri().then<Null>((Null a) => _checkSpotLight());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _leave();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Null> _connect() async {
    print("main_page _connect");

    //shuttertop.userRepository.join(shuttertop.currentSession.user);
  }

  Future<Null> _leave() async {
    //if (shuttertop.currentSession != null)
    //  shuttertop.userRepository.leave(shuttertop.currentSession.user);
  }

  void _onTap() {
    _index++;
    spotlight(_index);
  }

  Future<Null> _checkUri() async {
    if (shuttertop.link != null) {
      final Uri uri = shuttertop.link;
      print("------checkUri!!");
      if (uri != null && uri.pathSegments.isNotEmpty) {
        new Future<void>.delayed(const Duration(milliseconds: 200), () async {
          switch (uri.pathSegments.first) {
            case "another_life_confirm":
              final String email = uri.queryParameters["email"];
              final String token = uri.queryParameters["token"];
              print("another_life_confirm email: $email token: $token");
              await WidgetUtils.showPasswordConfirmPage(context,
                  token: token, email: email);
              break;
            case "contests":
              if (uri.pathSegments.length > 1) {
                final String slug = uri.pathSegments[1];
                await WidgetUtils.showContestPage(
                    context, await shuttertop.contestRepository.get(slug),
                    join: false, showComments: false, initLoad: false);
              }
              break;
            case "photos":
              if (uri.pathSegments.length > 1) {
                final String slug = uri.pathSegments[1];
                await WidgetUtils.showPhotoPage(
                    context, await shuttertop.photoRepository.get(slug),
                    showComments: false);
              }
              break;
            case "users":
              if (uri.pathSegments.length > 1) {
                final String slug = uri.pathSegments[1];
                await WidgetUtils.showUserPage(
                    context, await shuttertop.userRepository.get(slug));
              }
              break;
            default:
          }
        });
      }
    }

    return null;
  }

  Future<Null> _checkSpotLight() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('spotlight_home') ?? false))
      Future<dynamic>.delayed(Duration(seconds: 1)).then((dynamic value) {
        spotlight(0);
        prefs.setBool("spotlight_home", true);
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("---main_page didChangeAppLifecycleState state=${state.toString()}");
    if (state == AppLifecycleState.paused)
      shuttertop.disconnect(true);
    else if (state == AppLifecycleState.resumed) {
      _connect();
    }
  }

  void navigationTapped(int page) {
    setState(() {
      _page = page;
      currentPage = pages[page];
    });
  }

  Future<Null> _showCreateContest() async {
    final Contest contest = await Navigator.of(context).push(
        new MaterialPageRoute<Contest>(
            settings: const RouteSettings(name: ContestCreatePage.routeName),
            builder: (BuildContext context) => ContestCreatePage()));
    if (contest != null) {
      //_isFilterChanging = true;
      setState(() {
        //_contestsAdded += 1;
      });
      print("contest creato: ${contest.name}");
      //_isFilterChanging = false;
      WidgetUtils.showContestPage(context, contest,
          join: false, showComments: false);
      //setState(() {});
    } else
      print("nessun contest creato");
  }

  @override
  Widget build(BuildContext context) {
    //final TextStyle bottomBarTextStyle = TextStyle();
    final Scaffold _scaffold = Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: currentPage,
        floatingActionButton: _page == 1
            ? FloatingActionButton(
                elevation: 1.5,
                backgroundColor: Colors.white,
                onPressed: _showCreateContest,
                child: Icon(
                  Icons.add,
                  color: Colors.grey[800],
                  size: 32.0,
                ))
            : null,
        drawer: shuttertop.currentSession == null ? null : MainDrawer(),
        bottomNavigationBar: new Theme(
            data: Theme.of(context).copyWith(
                //primaryColor: AppColors.brandPrimary,
                primaryColor: Colors.grey[700],
                backgroundColor: Colors.white,
                bottomAppBarColor: Colors.white,
                accentTextTheme: TextTheme(
                    caption: TextStyle(
                        fontFamily: "Raleway",
                        fontSize: 14.0,
                        color: Colors.grey[500])),
                textTheme: TextTheme(
                    caption: TextStyle(
                        //fontFamily: "Raleway",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400]))),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                    ),
                    title: Text(
                      "Home",
                      style: TextStyle(
                          //fontFamily: "Raleway",
                          ),
                    )),
                BottomNavigationBarItem(
                    icon: Icon(Icons.filter),
                    title: Text(
                      "Contest",
                      style: TextStyle(),
                    )),
                BottomNavigationBarItem(
                    icon: Icon(Icons.equalizer),
                    title: Text(
                      "Classifiche",
                      style: TextStyle(),
                    )),
                BottomNavigationBarItem(
                    icon: IconBadge(
                        Icons.mail_outline,
                        shuttertop.currentSession.notifyCount > 0 ||
                            shuttertop.currentSession.notifyMessageCount > 0),
                    title: Text(
                      "Posta",
                      style: TextStyle(),
                    )),
              ],
              currentIndex: _page,
              onTap: navigationTapped,
            )));
    return Spotlight(
        center: _center,
        radius: _radius,
        enabled: _enabled,
        description: _description,
        animation: true,
        onTap: _onTap,
        color: Color.fromRGBO(0, 0, 0, 0.8),
        child: _scaffold);
  }
}
