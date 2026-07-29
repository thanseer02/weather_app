import 'package:flutter/material.dart';
import '../constants/app_shadows.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primarySeed,
      brightness: Brightness.light,
      extensions: const [
        AppThemeExtension(
          glassColor: Color(0x4DFFFFFF), // 30% white
          gradientBackground: AppColors.lightGradient,
          cardShadows: AppShadows.light,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primarySeed,
      brightness: Brightness.dark,
      extensions: const [
        AppThemeExtension(
          glassColor: Color(0x1AFFFFFF), // 10% white
          gradientBackground: AppColors.darkGradient,
          cardShadows: AppShadows.dark,
        ),
      ],
    );
  }
}
