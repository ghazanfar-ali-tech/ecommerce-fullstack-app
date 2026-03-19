import 'dart:math' as math;

import 'package:flutter/material.dart';

class OneTimeSweepPainter extends CustomPainter {
  final double progress;
  final Color iconColor;
  OneTimeSweepPainter({required this.progress, required this.iconColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final x    = size.width * 1.8 * progress - size.width * 0.4;
    final peak = math.sin(progress * math.pi);

    final colorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          iconColor.withOpacity(0.3 * peak),
          iconColor.withOpacity(0.18 * peak),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(x - 24, 0, 48, size.height));

    final colorPath = Path()
      ..moveTo(x - 24, 0)
      ..lineTo(x + 14, 0)
      ..lineTo(x - 6,  size.height)
      ..lineTo(x - 44, size.height)
      ..close();
    canvas.drawPath(colorPath, colorPaint);


    final whitePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.6 * peak),
          Colors.white.withOpacity(0.75 * peak),
          Colors.white.withOpacity(0.6 * peak),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(x - 8, 0, 16, size.height));

    final whitePath = Path()
      ..moveTo(x - 8, 0)
      ..lineTo(x + 4, 0)
      ..lineTo(x - 4, size.height)
      ..lineTo(x - 16, size.height)
      ..close();
    canvas.drawPath(whitePath, whitePaint);
  }

  @override
  bool shouldRepaint(OneTimeSweepPainter old) =>
      old.progress != progress || old.iconColor != iconColor;
}