import 'package:flutter/material.dart';

/// iPad layout wrapper for ReportsPage — centered with max width
class ReportsPageIpad extends StatelessWidget {
  final Widget child;

  const ReportsPageIpad({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: child,
      ),
    );
  }
}
