import 'package:flutter/material.dart';

class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    const cols = 4;
    const rows = 3;
    final gx = size.width / cols;
    final gy = size.height / rows;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
            Offset(gx * c + gx / 2, gy * r + gy / 2), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter old) => false;
}