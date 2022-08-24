import 'dart:async';
import 'dart:io';

// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/events.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/pages/main_page.dart';
import 'package:shuttertop/pages/welcome_page.dart';
import 'package:uni_links/uni_links.dart';

class AppWidget extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<AppWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String _latestLink = 'Unknown';
  static const MethodChannel platform =
      const MethodChannel('app.channel.shared.data');

  StreamSubscription<String> _sub;
  SpecifiedLocalizationDelegate _localeOverrideDelegate;
/*

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
*/
  @override
  void initState() {
    super.initState();
    _localeOverrideDelegate = new SpecifiedLocalizationDelegate(null);
    WidgetsBinding.instance.addObserver(this);
    shuttertop.eventBus.on<LocaleChangedEvent>().listen((LocaleChangedEvent e) {
      setState(() {
        _localeOverrideDelegate = new SpecifiedLocalizationDelegate(e.locale);
      });
    });
    getSharedImage();

    initPlatformStateForStringUniLinks();
  }

  @override
  void dispose() {
    if (_sub != null) _sub.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onLocaleChange(Locale l) {
    setState(() {
      _localeOverrideDelegate = new SpecifiedLocalizationDelegate(l);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(
        "---shuttertop_app didChangeAppLifecycleState state=${state.toString()}");
    if (state == AppLifecycleState.paused)
      print("paused");
    else if (state == AppLifecycleState.resumed) {
      getSharedImage();
      initPlatformStateForStringUniLinks();
    }
  }

  void getSharedImage() async {
    print("shuttertop_app getSharedData");
    final String sharedData = await platform.invokeMethod("getSharedImage");
    if (sharedData != null) {
      print("shuttertop_app sharedData!!!! $sharedData");
      final File fileName = await ImagePicker.pickImage(
          source: ImageSource.path,
          maxWidth: 1200.0,
          maxHeight: 1200.0,
          imagePath: sharedData);
      print("shuttertop_app sharedImage1!!!!!! $fileName");
      ShuttertopApp().eventBus.fire(new ImageSharedEvent(fileName));
      //.sharedImage = fileName;
    }
  }

  /// An implementation using a [String] link
  Future<Null> initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      setState(() {
        _latestLink = link ?? 'Unknown';
        try {
          if (link != null) checkLink(_latestLink);
        } on FormatException {
          print("ERROR - format _latestLink $_latestLink");
        }
      });
    }, onError: (dynamic err) {
      if (!mounted) return;
      setState(() {
        _latestLink = 'Failed to get latest link: $err.';
      });
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      print('got link: $link');
    }, onError: (dynamic err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = initialLink;
      if (_latestLink != null) checkLink(_latestLink);
    });
  }

  void checkLink(String link) {
    print("checkLink");
    try {
      shuttertop.link = Uri.parse(link);
    } catch (err) {
      print("ERRORE checkLink: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final FirebaseAnalytics analytics = FirebaseAnalytics();
    return new MaterialApp(
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          _localeOverrideDelegate,
          new AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: <Locale>[
          const Locale('en', 'US'),
          const Locale('it', 'IT'),
          const Locale('es', 'ES'),
          const Locale('pt', 'PT'),
        ],
        title: 'Shuttertop',
        theme: new ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.pinkAccent,
            primarySwatch: Colors.pink,
            scaffoldBackgroundColor: Colors.white,
            backgroundColor: Colors.white,
            fontFamily: "Roboto"),
        // navigatorObservers: <NavigatorObserver>[observer],
        routes: <String, WidgetBuilder>{
          WelcomePage.routeName: (BuildContext context) => new WelcomePage(),
          MainPage.routeName: (BuildContext context) => const MainPage()
        });
  }
}
