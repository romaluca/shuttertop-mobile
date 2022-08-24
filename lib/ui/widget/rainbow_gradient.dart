import 'package:flutter/widgets.dart';

class RainbowGradient extends LinearGradient {
  RainbowGradient({
    List<Color> colors = const <Color>[
      const Color(0xFFFF0064),
      const Color(0xFFFF7600),
      const Color(0xFFFFD500),
      const Color(0xFF8CFE00),
      const Color(0xFF00E86C),
      const Color(0xFF00F4F2),
      const Color(0xFF00CCFF),
      const Color(0xFF70A2FF),
      const Color(0xFFA96CFF),
    ],
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.topRight,
  }) : super(
          begin: begin,
          end: end,
          colors: _buildColors(colors),
          stops: _buildStops(colors),
        );

  static List<Color> _buildColors(List<Color> colors) {
    return colors.fold<List<Color>>(<Color>[],
        (List<Color> list, Color color) => list..addAll(<Color>[color, color]));
  }

  static List<double> _buildStops(List<Color> colors) {
    final List<double> stops = <double>[0.0];
    final int len = colors.length;
    for (int i = 1; i < len; i++) {
      stops.add(i / colors.length);
      stops.add(i / colors.length);
    }

    return stops..add(1.0);
  }
}
