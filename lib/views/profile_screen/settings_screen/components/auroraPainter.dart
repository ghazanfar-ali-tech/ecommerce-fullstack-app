import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuroraPainter extends CustomPainter {
  final double progress;
  final int sectionIndex;

  AuroraPainter({required this.progress, required this.sectionIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final stagger = (sectionIndex * 0.15);
    final t = ((progress - stagger) / (1.0 - stagger)).clamp(0.0, 1.0);
    if (t <= 0) return;

    final sweep = Curves.easeInOut.transform(t);
    final x     = size.width * 1.6 * sweep - size.width * 0.3;
    final peak  = math.sin(t * math.pi); 

    final auroraPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF003DB5).withOpacity(0.06 * peak),
          const Color(0xFF0284C7).withOpacity(0.10 * peak),
          const Color(0xFF38BDF8).withOpacity(0.14 * peak),
          const Color(0xFF0284C7).withOpacity(0.10 * peak),
          const Color(0xFF003DB5).withOpacity(0.06 * peak),
          Colors.transparent,
        ],
        stops: const [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
      ).createShader(Rect.fromLTWH(x - 120, 0, 240, size.height));

    final auroraPath = Path()
      ..moveTo(x - 120, 0)
      ..lineTo(x + 80,  0)
      ..lineTo(x + 50,  size.height)
      ..lineTo(x - 150, size.height)
      ..close();
    canvas.drawPath(auroraPath, auroraPaint);

    
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.18 * peak),
          Colors.white.withOpacity(0.28 * peak),
          Colors.white.withOpacity(0.18 * peak),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(x - 24, 0, 48, size.height));

    final glossPath = Path()
      ..moveTo(x - 24, 0)
      ..lineTo(x + 14, 0)
      ..lineTo(x - 4,  size.height)
      ..lineTo(x - 42, size.height)
      ..close();
    canvas.drawPath(glossPath, glossPaint);

   
    final cyanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF8BFCFE).withOpacity(0.08 * peak),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(x + 20, 0, 80, size.height));

    final cyanPath = Path()
      ..moveTo(x + 20, 0)
      ..lineTo(x + 100, 0)
      ..lineTo(x + 80,  size.height)
      ..lineTo(x,       size.height)
      ..close();
    canvas.drawPath(cyanPath, cyanPaint);
  }

  @override
  bool shouldRepaint(AuroraPainter old) =>
      old.progress != progress;
}