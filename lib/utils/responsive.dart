import 'package:get/get.dart';

class Responsive {
  static double get width => Get.width;
  static double get height => Get.height;

  static bool get isMobile => width < 600;
  static bool get isTablet => width >= 600 && width < 1100;
  static bool get isDesktop => width >= 1100;

  // Padding
  static double get horizontalPadding =>
      isMobile ? 16 : isTablet ? 24 : 40;

  // Grid columns
  static int get gridCount =>
      isMobile ? 2 : isTablet ? 3 : 4;

  // Header height
  static double get headerHeight =>
      isMobile ? height * 0.38 : height * 0.45;

  static double get headerMaxWidth =>
    isMobile ? double.infinity : isTablet ? 900 : 1200;

  // Carousel height
  static double get carouselHeight =>
      isMobile ? 200 : isTablet ? 260 : 320;

  // Font scaling
  static double font(double size) {
    if (isMobile) return size;
    if (isTablet) return size * 1.15;
    return size * 1.3;
  }
}
