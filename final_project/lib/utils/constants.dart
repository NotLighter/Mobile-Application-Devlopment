// lib/utils/constants.dart

import 'package:flutter/material.dart';

/// App-wide constant values, colors, URLs, padding, etc.
class AppConstants {
  // App Information
  static const String appName = "YourAppName";

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);

  // API Endpoints (example)
  static const String baseUrl = "https://api.yourapp.com";
  static const String loginEndpoint = "$baseUrl/login";
  static const String registerEndpoint = "$baseUrl/register";

  // Assets
  static const String logoPath = "assets/images/logo.png";
  static const String defaultAvatar = "assets/images/default_avatar.png";
}

/// Colors used throughout the app.
/// Keep all theme colors centralized here.
class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFF009688);

  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  static const Color cardBackground = Colors.white;

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
}

/// Predefined Text Styles used across the app.
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );
}
