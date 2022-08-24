import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:shuttertop/misc/secrets.dart';
import 'package:shuttertop/misc/shuttertop.dart';
import 'package:shuttertop/app.dart';

const ModeRun _mode = ModeRun.production;

Future<Null> main(List<String> arguments) async {
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
    final SentryResponse response = await shuttertop.sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );

    if (response.isSuccessful) {
      print('Success! Event ID: ${response.eventId}');
    } else {
      print('Failed to report to Sentry.io: ${response.error}');
    }
  });
  //final int helloAlarmID = 0;
  //await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}
