import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget customField({
  required String hintName,
  required IconData icon,
  String? labelText,
  TextEditingController? controller,
  bool obscure = false,
  String? Function(String?)? validator,
  required BuildContext context,
}) {
  final themeProvider = context.watch<ThemeProvider>();
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
    decoration: InputDecoration(
      hintText: hintName,
      labelText: labelText,
      hintStyle: TextStyle(
        color: themeProvider.isDark ? AppColors.primaryLight : Colors.grey,
      ),
      labelStyle: TextStyle(
        color: AppColors.textSecondary(context),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Color.fromARGB(255, 94, 160, 235)),
      filled: true,
      fillColor: AppColors.cardBackground(context),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),

      errorStyle: TextStyle(color: AppColors.error, fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
