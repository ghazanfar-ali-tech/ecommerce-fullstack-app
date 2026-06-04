import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';

Widget productFields({
  required String hintName,
  required IconData icon,
  required int minLines,
  TextInputType keyboardtype = TextInputType.text,
  String? labelText,
  TextEditingController? controller,
  String? Function(String?)? validator,
}) {
  return Builder(
    builder: (context) {
      return TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardtype,
        minLines: minLines,
        maxLines: minLines > 1 ? null : 1,
        style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
        decoration: InputDecoration(
          hintText: hintName,
          labelText: labelText,
          hintStyle: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
          ),
          labelStyle: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.surfaceVariant(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border(context), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: minLines > 1 ? 14 : 0,
          ),
        ),
      );
    },
  );
}
