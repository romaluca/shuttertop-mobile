
import 'package:flutter/material.dart';

class RoundedClipper extends CustomClipper<Path> {
  RoundedClipper( {this.round = 10.0});
  double round;

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

    @override
  Path getClip(Size size) {
      final Path path = new Path();
      
    path.lineTo(0.0, size.height - round);
    path.quadraticBezierTo(0.0, size.height, round, size.height);
    path.lineTo(size.width - round, size.height);
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - round);
    path.lineTo(size.width, round);
    path.quadraticBezierTo(size.width, round, size.width - round, 0.0);
    path.lineTo(round, 0.0);
    path.quadraticBezierTo(0.0, 0.0, 0.0, round);
      // Draws a straight line from current point to the first point of the path.
      // In this case (0, 0), since that's where the paths start by default.
      path.close();
      return path;
  }
}