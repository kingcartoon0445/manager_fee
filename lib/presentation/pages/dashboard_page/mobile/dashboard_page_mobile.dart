import 'package:flutter/material.dart';
import '../../../../core/animations.dart';

class DashboardPageMobile extends StatelessWidget {
  final Widget header;
  final Widget balanceSection;
  final Widget quickActionBanner;
  final Widget netFlow;
  final Widget budgetSection;
  final Widget dailyExpenseDetails;

  const DashboardPageMobile({
    super.key,
    required this.header,
    required this.balanceSection,
    required this.quickActionBanner,
    required this.netFlow,
    required this.budgetSection,
    required this.dailyExpenseDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 24),
          balanceSection,
          const SizedBox(height: 24),
          quickActionBanner,
          const SizedBox(height: 24),
          netFlow,
          const SizedBox(height: 24),
          budgetSection,
          const SizedBox(height: 16),
          SlideUpAnimation(
            delay: const Duration(milliseconds: 350),
            child: dailyExpenseDetails,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
