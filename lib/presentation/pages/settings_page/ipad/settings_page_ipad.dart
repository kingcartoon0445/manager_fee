import 'package:flutter/material.dart';

/// iPad layout wrapper for SettingsPage — centered with max width
class SettingsPageIpad extends StatelessWidget {
  final Widget child;

  const SettingsPageIpad({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: child,
      ),
    );
  }
}
