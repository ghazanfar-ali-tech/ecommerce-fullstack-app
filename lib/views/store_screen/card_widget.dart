import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget brandCard({
  required String savgImage,
  required String name,
  required String products,
  required Color color
}) {
  return Container(
    height: 80,
    width: 160,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Row(
      children: [
         SvgPicture.asset(
          savgImage,
          height: 36,
          width: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
              ],
            ),
            Text(
              products,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );
}
