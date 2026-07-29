import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

enum AdaptiveBreakpoint {
  mobile(0, 640),
  tablet(640, 1024),
  desktop(1024, 1440),
  largeDesktop(1440, 1920),
  ultraWide(1920, double.infinity);

  final double minWidth;
  final double maxWidth;
  const AdaptiveBreakpoint(this.minWidth, this.maxWidth);

  static AdaptiveBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    for (final breakpoint in values) {
      if (width >= breakpoint.minWidth && width < breakpoint.maxWidth) {
        return breakpoint;
      }
    }
    return mobile;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AdaptiveBreakpoint breakpoint) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget? ultraWide;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.ultraWide,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoint = AdaptiveBreakpoint.of(context);
    
    switch (breakpoint) {
      case AdaptiveBreakpoint.mobile:
        if (mobile != null) return mobile!;
      case AdaptiveBreakpoint.tablet:
        if (tablet != null) return tablet!;
      case AdaptiveBreakpoint.desktop:
        if (desktop != null) return desktop!;
      case AdaptiveBreakpoint.largeDesktop:
        if (largeDesktop != null) return largeDesktop ?? desktop!;
      case AdaptiveBreakpoint.ultraWide:
        if (ultraWide != null) return ultraWide ?? largeDesktop ?? desktop!;
    }
    
    return builder(context, breakpoint);
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final int largeDesktopCrossAxisCount;
  final int ultraWideCrossAxisCount;
  final double spacing;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount = 1,
    this.tabletCrossAxisCount = 2,
    this.desktopCrossAxisCount = 3,
    this.largeDesktopCrossAxisCount = 4,
    this.ultraWideCrossAxisCount = 6,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        int crossAxisCount;
        switch (breakpoint) {
          case AdaptiveBreakpoint.mobile:
            crossAxisCount = mobileCrossAxisCount;
          case AdaptiveBreakpoint.tablet:
            crossAxisCount = tabletCrossAxisCount;
          case AdaptiveBreakpoint.desktop:
            crossAxisCount = desktopCrossAxisCount;
          case AdaptiveBreakpoint.largeDesktop:
            crossAxisCount = largeDesktopCrossAxisCount;
          case AdaptiveBreakpoint.ultraWide:
            crossAxisCount = ultraWideCrossAxisCount;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class AdaptiveNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final Widget child;

  const AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        if (breakpoint == AdaptiveBreakpoint.mobile) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations.map((d) => NavigationDestination(icon: d.icon, label: d.label)).toList(),
            ),
          );
        }

        final showExpanded = breakpoint == AdaptiveBreakpoint.largeDesktop || breakpoint == AdaptiveBreakpoint.ultraWide;

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: showExpanded,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: destinations
                    .map((d) => NavigationRailDestination(
                          icon: d.icon,
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class AdaptiveSpacing extends StatelessWidget {
  final Widget? child;
  const AdaptiveSpacing({super.key, this.child});

  static double of(BuildContext context) {
    final breakpoint = AdaptiveBreakpoint.of(context);
    switch (breakpoint) {
      case AdaptiveBreakpoint.mobile:
        return 12.0;
      case AdaptiveBreakpoint.tablet:
        return 16.0;
      case AdaptiveBreakpoint.desktop:
        return 24.0;
      case AdaptiveBreakpoint.largeDesktop:
        return 32.0;
      case AdaptiveBreakpoint.ultraWide:
        return 48.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final val = of(context);
    return Padding(
      padding: EdgeInsets.all(val),
      child: child,
    );
  }
}

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final breakpoint = AdaptiveBreakpoint.of(context);
    double scaleFactor = 1.0;
    switch (breakpoint) {
      case AdaptiveBreakpoint.mobile:
        scaleFactor = 0.9;
      case AdaptiveBreakpoint.tablet:
        scaleFactor = 1.0;
      case AdaptiveBreakpoint.desktop:
        scaleFactor = 1.1;
      case AdaptiveBreakpoint.largeDesktop:
        scaleFactor = 1.25;
      case AdaptiveBreakpoint.ultraWide:
        scaleFactor = 1.4;
    }

    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final finalStyle = baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14.0) * scaleFactor,
    );

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
    );
  }
}

class AdaptiveCards extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const AdaptiveCards({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        double cardScale = 1.0;
        switch (breakpoint) {
          case AdaptiveBreakpoint.mobile:
            cardScale = 0.95;
          case AdaptiveBreakpoint.tablet:
            cardScale = 1.0;
          case AdaptiveBreakpoint.desktop:
            cardScale = 1.05;
          case AdaptiveBreakpoint.largeDesktop:
            cardScale = 1.1;
          case AdaptiveBreakpoint.ultraWide:
            cardScale = 1.2;
        }

        return Transform.scale(
          scale: cardScale,
          child: GlassCard(
            width: width,
            height: height,
            child: child,
          ),
        );
      },
    );
  }
}
