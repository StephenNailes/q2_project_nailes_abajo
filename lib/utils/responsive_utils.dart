import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 360 && width < 600;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 600;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) {
      return baseSize * 0.9;
    } else if (isLargeScreen(context)) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  static double getResponsivePadding(BuildContext context, double basePadding) {
    if (isSmallScreen(context)) {
      return basePadding * 0.8;
    } else if (isLargeScreen(context)) {
      return basePadding * 1.2;
    }
    return basePadding;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.all(12);
    } else if (isLargeScreen(context)) {
      return const EdgeInsets.all(20);
    }
    return const EdgeInsets.all(16);
  }
}
