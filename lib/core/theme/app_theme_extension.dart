import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color glassColor;
  final List<Color> gradientBackground;
  final List<BoxShadow> cardShadows;

  const AppThemeExtension({
    required this.glassColor,
    required this.gradientBackground,
    required this.cardShadows,
  });

  @override
  AppThemeExtension copyWith({
    Color? glassColor,
    List<Color>? gradientBackground,
    List<BoxShadow>? cardShadows,
  }) {
    return AppThemeExtension(
      glassColor: glassColor ?? this.glassColor,
      gradientBackground: gradientBackground ?? this.gradientBackground,
      cardShadows: cardShadows ?? this.cardShadows,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      glassColor: Color.lerp(glassColor, other.glassColor, t)!,
      gradientBackground: [
        Color.lerp(gradientBackground[0], other.gradientBackground[0], t)!,
        Color.lerp(gradientBackground[1], other.gradientBackground[1], t)!,
      ],
      cardShadows: BoxShadow.lerpList(cardShadows, other.cardShadows, t) ?? cardShadows,
    );
  }
}
