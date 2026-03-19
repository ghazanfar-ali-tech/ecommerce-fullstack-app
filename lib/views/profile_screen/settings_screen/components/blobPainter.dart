import 'dart:math' as math;
import 'package:flutter/material.dart';

class BlobPainter extends CustomPainter {
  final double progress;
  BlobPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final path = Path();
    const pts = 8;
    for (int i = 0; i <= pts; i++) {
      final a = (i / pts) * 2 * math.pi;
      final r = 36 +
          12 * math.sin(a * 3 + progress * math.pi * 2) +
          7  * math.cos(a * 2 + progress * math.pi);
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BlobPainter old) => old.progress != progress;
}