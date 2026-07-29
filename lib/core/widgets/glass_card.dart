import 'package:flutter/material.dart';
import '../constants/app_radius.dart';
import '../theme/app_theme_extension.dart';
import '../utils/glassmorphism_utils.dart';

class GlassCard extends StatefulWidget {
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
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final glassColor = themeExt?.glassColor ?? Colors.white.withValues(alpha: 0.2);
    final activeColor = _isHovered ? glassColor.withValues(alpha: 0.3) : glassColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          child: GlassmorphismUtils.applyGlass(
            color: activeColor,
            borderRadius: widget.borderRadius ?? AppRadius.borderLg,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16.0),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
