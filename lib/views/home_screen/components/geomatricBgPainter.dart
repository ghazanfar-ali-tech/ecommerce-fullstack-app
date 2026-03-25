import 'dart:math' as math;
import 'package:flutter/material.dart';

class GeometricBgPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  GeometricBgPainter({required this.progress, required this.isDark});

  double get t => progress * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawGlow(canvas, Offset(w - 30 + 6 * math.sin(t * 0.7), 10 + 5 * math.cos(t * 0.5)), 90, isDark);
    _drawGlow(canvas, Offset(18 + 5 * math.cos(t * 0.6), h - 28 + 6 * math.sin(t * 0.8)), 70, isDark);
    _drawGlow(canvas, Offset(w * 0.5 + 10 * math.sin(t * 0.4), h * 0.5 + 8 * math.cos(t * 0.3)), 50, isDark);

    final hexScale1 = 1.0 + 0.06 * math.sin(t * 0.9);
    _drawHexagon(
      canvas,
      center: Offset(w - 38 + 4 * math.sin(t * 0.5), -10 + 4 * math.cos(t * 0.4)),
      radius: 58 * hexScale1,
      rotation: t * 0.15,
      paint: Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(isDark ? 0.18 : 0.22),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: Offset(w - 38, -10), radius: 58))
        ..style = PaintingStyle.fill,
    );

    _drawHexagon(
      canvas,
      center: Offset(w - 95 + 5 * math.cos(t * 0.7), 55 + 6 * math.sin(t * 0.6)),
      radius: 32,
      rotation: -t * 0.2,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.13 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _drawHexagon(
      canvas,
      center: Offset(w - 22 + 8 * math.sin(t * 0.5 + 1.0), h - 22 + 6 * math.cos(t * 0.6)),
      radius: 22,
      rotation: t * 0.3,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.10 : 0.14)
        ..style = PaintingStyle.fill,
    );

    _drawHexagon(
      canvas,
      center: Offset(22 + 6 * math.sin(t * 0.4 + 0.5), h * 0.4 + 10 * math.cos(t * 0.5)),
      radius: 18,
      rotation: -t * 0.25,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.08 : 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    _drawTriangle(
      canvas,
      center: Offset(18 + 5 * math.cos(t * 0.6), h - 28 + 7 * math.sin(t * 0.5)),
      size: 48,
      rotation: 0.3 + t * 0.1,
      paint: Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(isDark ? 0.16 : 0.20),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: Offset(18, h - 28), radius: 48))
        ..style = PaintingStyle.fill,
    );

    final triScale1 = 1.0 + 0.08 * math.sin(t * 1.1);
    _drawTriangle(
      canvas,
      center: Offset(30 + 4 * math.sin(t * 0.8), 30 + 4 * math.cos(t * 0.7)),
      size: 22 * triScale1,
      rotation: -0.5 - t * 0.15,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.12 : 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    _drawTriangle(
      canvas,
      center: Offset(w - 25 + 7 * math.cos(t * 0.5), h - 70 + 8 * math.sin(t * 0.6)),
      size: 28,
      rotation: 1.2 + t * 0.2,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.10 : 0.13)
        ..style = PaintingStyle.fill,
    );

    _drawTriangle(
      canvas,
      center: Offset(w - 15 + 5 * math.sin(t * 0.9), h * 0.5 + 10 * math.cos(t * 0.4)),
      size: 20,
      rotation: t * 0.25,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.09 : 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    _drawDiamond(
      canvas,
      center: Offset(w * 0.25 + 8 * math.sin(t * 0.5), 20 + 6 * math.cos(t * 0.6)),
      size: 14,
      rotation: t * 0.2,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.10 : 0.14)
        ..style = PaintingStyle.fill,
    );
    _drawDiamond(
      canvas,
      center: Offset(w * 0.75 + 6 * math.cos(t * 0.7), h - 18 + 5 * math.sin(t * 0.5)),
      size: 12,
      rotation: -t * 0.3,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.09 : 0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final dotPaint = Paint()..style = PaintingStyle.fill;
    final dotData = [
      [w - 130.0, 22.0, 2.5, 0.0],
      [w - 115.0, 38.0, 1.8, 0.5],
      [w - 148.0, 42.0, 1.5, 1.0],
      [55.0, h - 95, 2.5, 1.5],
      [38.0, h - 110, 1.8, 2.0],
      [70.0, h - 112, 1.5, 2.5],
      [w * 0.3, h * 0.15, 2.0, 3.0],
      [w * 0.7, h * 0.85, 1.8, 3.5],
    ];
    for (final d in dotData) {
      final pulse = 0.15 + 0.10 * math.sin(t + d[3]);
      dotPaint.color = Colors.white.withOpacity(isDark ? pulse : pulse + 0.05);
      final dx = d[0] + 4 * math.sin(t * 0.6 + d[3]);
      final dy = d[1] + 4 * math.cos(t * 0.5 + d[3]);
      canvas.drawCircle(Offset(dx, dy), d[2], dotPaint);
    }

    final linePaint = Paint()..strokeWidth = 1.0;

    linePaint.color = Colors.white.withOpacity(isDark ? 0.08 : 0.11);
    canvas.drawLine(
      Offset(w - 110 + 3 * math.sin(t * 0.4), 0),
      Offset(w - 60 + 3 * math.cos(t * 0.4), 80),
      linePaint,
    );
    canvas.drawLine(
      Offset(0, h - 80 + 3 * math.sin(t * 0.5)),
      Offset(80, h - 20 + 3 * math.cos(t * 0.5)),
      linePaint,
    );
    
    linePaint.color = Colors.white.withOpacity(isDark ? 0.06 : 0.09);
    canvas.drawLine(
      Offset(w * 0.2 + 4 * math.sin(t * 0.3), 0),
      Offset(w * 0.35 + 4 * math.cos(t * 0.3), h * 0.3),
      linePaint,
    );
  }

  void _drawGlow(Canvas canvas, Offset center, double radius, bool isDark) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(isDark ? 0.10 : 0.13),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawHexagon(Canvas canvas, {required Offset center, required double radius, required double rotation, required Paint paint}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawTriangle(Canvas canvas, {required Offset center, required double size, required double rotation, required Paint paint}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.866, size * 0.5)
      ..lineTo(-size * 0.866, size * 0.5)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawDiamond(Canvas canvas, {required Offset center, required double size, required double rotation, required Paint paint}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.6, 0)
      ..lineTo(0, size)
      ..lineTo(-size * 0.6, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GeometricBgPainter old) =>
      old.progress != progress || old.isDark != isDark;
}