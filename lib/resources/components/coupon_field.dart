import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';

Widget couponField({
  required TextEditingController controller,
  required VoidCallback onApply,
  String hintText = "Enter coupon code",
  double borderRadius = 12,
  Color borderColor = Colors.grey,
  Color buttonColor = Colors.orange,
  String buttonText = "Apply",
}) {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: buttonColor),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
     Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(borderRadius),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onApply,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ),
),
    ],
  );
}
