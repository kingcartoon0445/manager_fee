import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet }

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget tabletLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.tabletLayout,
  });

  static const double tabletBreakpoint = 600;

  static DeviceType getDeviceType(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= tabletBreakpoint
        ? DeviceType.tablet
        : DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (MediaQuery.of(context).size.shortestSide >= tabletBreakpoint) {
          return tabletLayout;
        }
        return mobileLayout;
      },
    );
  }
}
