import 'package:flutter/material.dart';
import '../constants/app_radius.dart';
import '../theme/app_theme_extension.dart';
import '../utils/glassmorphism_utils.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final glassColor = themeExt?.glassColor ?? Colors.white.withValues(alpha: 0.2);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: GlassmorphismUtils.applyGlass(
        color: glassColor,
        borderRadius: borderRadius ?? AppRadius.borderLg,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
