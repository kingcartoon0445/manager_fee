import 'package:flutter/material.dart';

/// Mobile layout wrapper for TransactionPage — full width
class TransactionPageMobile extends StatelessWidget {
  final Widget child;

  const TransactionPageMobile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
