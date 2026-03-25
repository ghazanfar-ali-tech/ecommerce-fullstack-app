
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class SunRayPainter extends CustomPainter {
  final Color color;
  SunRayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    const rays   = 8;
    const inner  = 20.0;
    const outer  = 28.0;

    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * 2 * math.pi;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
               center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle),
               center.dy + outer * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SunRayPainter old) => old.color != color;
}


class CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE8EAF6);

    final double r = size.width / 2;
    final center = Offset(r, r);


    final path = Path()..addOval(Rect.fromCircle(center: center, radius: r));

   
    final cutPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(r + r * 0.45, r - r * 0.1),
        radius: r * 0.85,
      ));

    final crescent = Path.combine(PathOperation.difference, path, cutPath);
    canvas.drawPath(crescent, paint);

    
    final craterPaint = Paint()..color = Colors.white.withOpacity(0.25);
    canvas.drawCircle(Offset(r * 0.45, r * 0.65), 2.5, craterPaint);
    canvas.drawCircle(Offset(r * 0.3, r * 0.9), 1.5, craterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
