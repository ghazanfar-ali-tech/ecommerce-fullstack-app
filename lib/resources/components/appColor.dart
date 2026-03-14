import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {

  // ==============================
  // Primary Brand Colors
  // ==============================
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryDark = Color(0xFF1E40AF);

  // ==============================
  // Ecommerce Action Buttons
  // ==============================

  // Main actions (Add to Cart, Buy Now, Checkout)
  static const Color primaryButton = Color(0xFFFF6F00);
  static const Color primaryButtonText = Colors.white;

  // Secondary buttons (View Details, Continue Shopping)
  static const Color secondaryButtonBorder = Color(0xFF1565C0);
  static const Color secondaryButtonText = Color(0xFF1565C0);

  // Disabled buttons
  static const Color disabledButton = Color(0xFFBDBDBD);
  static const Color disabledButtonText = Color(0xFF757575);

  // ==============================
  // Background Colors
  // ==============================
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA);

  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white;

  // ==============================
  // Text Colors
  // ==============================
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1F2A44);

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]!
          : Colors.grey[600]!;

  // ==============================
  // Icon Colors
  // ==============================
  static const Color iconPrimary = Color(0xFF3B82F6);

  static Color iconSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400]!
          : Colors.grey[600]!;

  // ==============================
  // Status Colors
  // ==============================
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF6B7280);

  // ==============================
  // Borders & Shadows
  // ==============================
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]!
          : Colors.grey[300]!;

  static Color shadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.3)
          : Colors.grey.withOpacity(0.2);
}