import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';

Widget customField({
  required String hintName,
  required IconData icon,
  String? labelText,
  TextEditingController? controller,
  bool obscure = false,
  String? Function(String?)? validator,
  required BuildContext context,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    style: TextStyle(
      color: AppColors.textPrimary(context),
      fontSize: 14,
    ),
    decoration: InputDecoration(
      hintText: hintName,
      labelText: labelText,
      hintStyle: TextStyle(color: AppColors.textHint(context), fontSize: 14),
      labelStyle: TextStyle(color: AppColors.textSecondary(context), fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.iconDefault(context), size: 20),
      filled: true,
      fillColor: AppColors.cardBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 0.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: TextStyle(color: AppColors.error, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}