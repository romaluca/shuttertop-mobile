import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shuttertop/misc/app_localizations.dart';
import 'package:shuttertop/misc/costants.dart';
import 'package:shuttertop/misc/utils.dart';
import 'package:shuttertop/models/contest.dart';

class ContestDetailsText extends StatefulWidget {
  const ContestDetailsText(this.contest,
      {Key key,
      this.onlyTime = false,
      this.short = false,
      this.fontSize = 16.0,
      this.fontColor = Colors.black87,
      this.margin,
      this.fontFamily,
      this.fontWeight = FontWeight.w300})
      : super(key: key);
  final Contest contest;
  final FontWeight fontWeight;
  final double fontSize;
  final String fontFamily;
  final Color fontColor;
  final bool onlyTime;
  final bool short;
  final EdgeInsets margin;

  @override
  _ContestDetailsTextState createState() => new _ContestDetailsTextState();
}

class _ContestDetailsTextState extends State<ContestDetailsText> {
  bool isTimeFormat;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    try {
      isTimeFormat = !widget.contest.isExpired &&
          widget.contest.expiryAt.difference(new DateTime.now()).inDays == 0;
      if (isTimeFormat) {
        _timer = new Timer.periodic(new Duration(seconds: 1), (Timer t) {
          setState(() {});
        });
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    }
  }

  String _getTimeRemain(bool short) {
    try {
      return Utils.getTimeRemain(widget.contest.expiryAt, short);
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return "";
    }
  }

  int _getPhotosCount() {
    try {
      return widget.contest.photosCount;
    } catch (error, stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
      return 0;
    }
  }

  @override
  void dispose() {
    if (isTimeFormat) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget ele = widget.onlyTime
        ? Text(
            _getTimeRemain(true).toUpperCase(),
            style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: widget.fontColor),
          )
        : RichText(
            text: TextSpan(
                style: TextStyle(
                    fontFamily: widget.fontFamily,
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                    color: widget.fontColor),
                children: <TextSpan>[
                  TextSpan(
                      style: isTimeFormat
                          ? TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500)
                          : null,
                      text: _getTimeRemain(widget.short)),
                  TextSpan(
                    text: " · " +
                        AppLocalizations.of(context)
                            .photosWithCount(_getPhotosCount()),
                  )
                ].where((TextSpan e) => e != null).toList()));
    return Container(
      child: ele,
      margin: widget.margin,
    );
  }
}
