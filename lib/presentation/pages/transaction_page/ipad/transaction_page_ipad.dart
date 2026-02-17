import 'package:flutter/material.dart';

/// iPad layout wrapper for TransactionPage — centered with max width
class TransactionPageIpad extends StatelessWidget {
  final Widget child;

  const TransactionPageIpad({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: child,
      ),
    );
  }
}
