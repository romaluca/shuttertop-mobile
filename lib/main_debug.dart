import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/app.dart';

const ModeRun _mode = ModeRun.debug;

Future<Null> main(List<String> arguments) async {
  //MaterialPageRoute.debugEnableFadingRoutes = true;
  FlutterError.onError = (FlutterErrorDetails details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };

  //runApp(configuredApp);
  shuttertop.init(
      mode: _mode,
      platform: defaultTargetPlatform == TargetPlatform.iOS
          ? PlatformApp.iOs
          : PlatformApp.android);
  runZoned<Future<Null>>(() async {
    runApp(new AppWidget());
  }, onError: (dynamic error, StackTrace stackTrace) async {
    print('Caught error: $error');
    print('Caught error: $stackTrace');
  });
  //final int helloAlarmID = 0;
  //await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}
