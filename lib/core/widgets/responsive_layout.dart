import 'package:flutter/material.dart';

import '../layout/adaptive_layout_system.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) => 
      AdaptiveBreakpoint.of(context) == AdaptiveBreakpoint.mobile;
  
  static bool isTablet(BuildContext context) => 
      AdaptiveBreakpoint.of(context) == AdaptiveBreakpoint.tablet;
  
  static bool isDesktop(BuildContext context) => 
      AdaptiveBreakpoint.of(context).minWidth >= AdaptiveBreakpoint.desktop.minWidth;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      builder: (context, breakpoint) => mobile,
    );
  }
}
