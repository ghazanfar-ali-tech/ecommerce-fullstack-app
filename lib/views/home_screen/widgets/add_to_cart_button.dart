import 'package:flutter/material.dart';

Widget addToCartButton(
  String text,
  IconData cartIcon,
  Color bgcolor,
  VoidCallback onPressed,
  Color textColor,
  double textSize,
  double iconSize,
) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50), 
            spreadRadius: 1, 
            blurRadius: 1,
            offset: Offset(1, 1), 
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(5)),
              child: Icon(
                cartIcon,
                size: iconSize,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 5), 
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: textSize,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
