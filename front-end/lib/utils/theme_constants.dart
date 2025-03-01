import 'package:flutter/material.dart';

class AppConstants {
  // API Constants
  static const String baseUrl = 'http://192.168.1.159:5000';
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Spacing Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Border Radius
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  
  // Card Elevation
  static const double defaultElevation = 2.0;
  
  // Image Constants
  static const double imageQuality = 80;
  static const double maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Text Styles
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}