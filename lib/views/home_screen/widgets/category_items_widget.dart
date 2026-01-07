import 'package:flutter/material.dart';

Widget buildCategoryItemFromFirestore(String imageUrl, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(7), 
            child: imageUrl.isNotEmpty
                ? FittedBox(
                    fit: BoxFit.contain, 
                    child: Image.network(
                      imageUrl,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : const Icon(Icons.image, color: Colors.grey),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              blurRadius: 6.0,
              color: Colors.black54,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    ],
  );
}
