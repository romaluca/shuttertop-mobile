import 'dart:ui';

import 'package:flutter/material.dart';

class Constants {
  static const Duration fadeInDuration = const Duration(milliseconds: 400);
}

class ImageAssets {
  static const String transparentImage = 'assets/images/1x1_transparent.png';
  static const String logo128 = 'assets/images/logo_128.png';
  static const String logoBack = 'assets/images/logo_back.png';
  static const String logoFront = 'assets/images/logo_front.png';
  static const String placeHolder = 'assets/images/placeholder.png';
}

class AppColors {
  // static const Color brandFirst = const Color(0xFFFF512F);
  // static const Color brandSecondary = const Color(0xFFDD2476);
  static const Color placeHolder = Color(0xFFF5F5F5);
  static const Color brandPrimary = const Color(0xffd81b60);
  // const Color(0xfff50057); //Color(0xFFE91E63);
  static const Color border = const Color(0x11000000);
  static const Color text = const Color(0xFF666666);
  static const Color textLight = const Color(0xFF999999);
  static const Color background = const Color(0xFFEEEEEE);
  static const Color tag = const Color(0xFF999999);
  static const Color medal = const Color(0xFFffbf00);

  static const Color linkAccent = const Color(0xffd81b60);

  // static const Color buttonBack = const Color(0xffd81b60);
  static const Color buttonFore = const Color(0xffffffff);

  static const Color inputBorderEnabled = const Color(0x22000000);

  static const List<LinearGradient> gradientsWinner = <LinearGradient>[
    LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [
          0.0,
          0.8,
          1.0
        ],
        colors: <Color>[
          Color(0xffDF9F28),
          Color(0xffFDE08D),
          Color(0xffbf9a53),
        ]),
    LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [
          0.0,
          0.8,
          1.0
        ],
        colors: <Color>[
          Color(0xffA9A9A9),
          Color(0xffEDEDED),
          Color(0xffBBBBBB),
        ]),
    LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [
          0.0,
          0.8,
          1.0
        ],
        colors: <Color>[
          Color(0xffb06e2e),
          Color(0xffFFC48B),
          Color(0xff804000),
        ])
  ];
}

class Styles {
  static final TextStyle header = TextStyle(
      fontFamily: "Raleway",
      fontWeight: FontWeight.w500,
      fontSize: 20.0,
      color: Colors.grey[800]);
  static final TextStyle subheader = TextStyle(
      fontFamily: "Raleway",
      //fontWeight: FontWeight.bold,
      fontWeight: FontWeight.w600,
      fontSize: 13.0,
      color: Colors.grey[500]);
  static final TextStyle subtitle =
      TextStyle(fontSize: 14.0, color: Colors.grey[500]);

  static final TextStyle labelStyle = TextStyle(
      fontFamily: "Raleway", fontSize: 16, fontWeight: FontWeight.w600);
}
