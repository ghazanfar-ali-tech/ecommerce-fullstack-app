import 'package:flutter/material.dart';

// ============================================================
// 60 - 30 - 10 COLOR RULE
// 60% → Cool white / deep navy  (backgrounds, text, borders)
// 30% → Deep navy → ocean blue  (brand, nav, buttons, icons)
// 10% → Warm orange             (CTA — Buy Now, Add to Cart)
// ============================================================

class AppColors {

  // ==============================
  // 60% — Neutral Base
  // ==============================
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF090E1A)
          : const Color(0xFFF5F8FF);

  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111827)
          : const Color(0xFFFFFFFF);

  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A2540)
          : const Color(0xFFEBF3FF);

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFE8F0FF)
          : const Color(0xFF0D1B3E);

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF6B7A99)
          : const Color(0xFF4A5878);

  static Color textHint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2E3D5C)
          : const Color(0xFFABB8D4);

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A2540)
          : const Color(0xFFDDE6F5);

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111827)
          : const Color(0xFFEEF4FF);

  static Color shadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.5)
          : const Color(0xFF003DB5).withOpacity(0.10);

  // ==============================
  // 30% — Deep Navy → Ocean Blue
  // ==============================
  static const Color primary      = Color(0xFF003DB5); // deep navy blue
  static const Color primaryEnd   = Color(0xFF0284C7); // ocean blue
  static const Color primaryDark  = Color(0xFF002E8A); // pressed state
  static const Color primaryDeep  = Color(0xFF001F5E); // dark mode deep
  static const Color primaryLight = Color(0xFFEBF3FF); // bg tint / chips
  static const Color primarySoft  = Color(0xFFBFDBFE); // soft tint

  // Main gradient — buttons, active nav, selected tabs
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF003DB5), Color(0xFF0284C7)],
  );

  // Hero / banner gradient
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF090E1A), Color(0xFF003DB5)],
  );

  // Subtle card tint — promo cards, featured sections
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF003DB5), Color(0xFF0284C7)],
  );

  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF60A5FA)
          : const Color(0xFF003DB5);

 static Color primaryContainer(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark
      ? Color.fromARGB(255, 34, 99, 230)
      : const Color(0xFFEBF3FF);
}

  // ==============================
  // 10% — Warm Orange CTA (Buy Now / Add to Cart only)
  // ==============================
  static const Color accent      = Color(0xFFFF6B35);
  static const Color accentDark  = Color(0xFFE85A24);
  static const Color accentDeep  = Color(0xFF7A2810);
  static const Color accentLight = Color(0xFFFFF1EC);
  static const Color accentSoft  = Color(0xFFFFD4C2);

  // CTA gradient — Buy Now, Add to Cart, Checkout
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
  );

  static Color accentText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFFB899)
          : const Color(0xFF7A2810);

  // ==============================
  // Semantic / Status Colors
  // ==============================
  static const Color success      = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error        = Color(0xFFEF4444);
  static const Color errorLight   = Color(0xFFFEE2E2);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info         = Color(0xFF3B82F6);
  static const Color infoLight    = Color(0xFFDBEAFE);

  // ==============================
  // Icon Colors
  // ==============================
  static const Color iconBrand = Color(0xFF003DB5);

  static Color iconDefault(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF6B7A99)
          : const Color(0xFF4A5878);

  // ==============================
  // Button Shadow Helper
  // ==============================
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: const Color(0xFF003DB5).withOpacity(0.35),
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> accentShadow = [
    BoxShadow(
      color: const Color(0xFFFF6B35).withOpacity(0.35),
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ];

  static Color iconAdaptive(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 34, 99, 230) // same as primaryContainer dark
        : Colors.black;
}