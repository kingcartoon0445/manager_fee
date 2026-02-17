import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../widgets/add_transaction_form.dart';
import '../../../widgets/quick_shopping_form.dart';
import '../dashboard_page.dart';
import '../../../widgets/ai_chat_panel.dart';

class DashboardPageIpad extends StatelessWidget {
  final Widget header;
  final Widget balanceSection;
  final Widget quickActionBanner;
  final Widget netFlow;
  final Widget budgetSection;
  final Widget dailyExpenseDetails;
  final RightPanelMode rightPanelMode;
  final Function(RightPanelMode) onSwitchMode;
  final VoidCallback onResetRightPanel;

  const DashboardPageIpad({
    super.key,
    required this.header,
    required this.balanceSection,
    required this.quickActionBanner,
    required this.netFlow,
    required this.budgetSection,
    required this.dailyExpenseDetails,
    required this.rightPanelMode,
    required this.onSwitchMode,
    required this.onResetRightPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Middle Section (Flex 3) - SCROLLABLE
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              children: [
                header,
                const SizedBox(height: 24),
                // Stacked Content
                balanceSection,
                const SizedBox(height: 24),
                quickActionBanner,
                const SizedBox(height: 24),
                netFlow,
                const SizedBox(height: 24),
                budgetSection,
                // Removed dailyExpenseDetails from here
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Right Section (Flex 2) - FIXED
        Expanded(
          flex: 2,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Header (Only for QuickShop/AI mode)
                if (rightPanelMode == RightPanelMode.quickShop ||
                    rightPanelMode == RightPanelMode.aiChat)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTitle(rightPanelMode),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (rightPanelMode == RightPanelMode.aiChat)
                          IconButton(
                            onPressed: () =>
                                onSwitchMode(RightPanelMode.addTransaction),
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.black54),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Custom Segmented Control (Only for Add/History)
                if (rightPanelMode == RightPanelMode.addTransaction ||
                    rightPanelMode == RightPanelMode.history)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            context,
                            title: 'Thêm giao dịch',
                            icon: Icons.add_circle_outline,
                            isActive:
                                rightPanelMode == RightPanelMode.addTransaction,
                            onTap: () =>
                                onSwitchMode(RightPanelMode.addTransaction),
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            context,
                            title: 'Lịch sử',
                            icon: Icons.history,
                            isActive: rightPanelMode == RightPanelMode.history,
                            onTap: () => onSwitchMode(RightPanelMode.history),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Dynamic Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(rightPanelMode),
                      child: _buildPanelContent(rightPanelMode),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTitle(RightPanelMode mode) {
    switch (mode) {
      case RightPanelMode.addTransaction:
        return 'Thêm Giao Dịch';
      case RightPanelMode.quickShop:
        return 'Đi Chợ Nhanh';
      case RightPanelMode.history:
        return 'Lịch Sử Hôm Nay';
      case RightPanelMode.aiChat:
        return 'Trợ Lý AI';
    }
  }

  Widget _buildSegmentButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent(RightPanelMode mode) {
    switch (mode) {
      case RightPanelMode.addTransaction:
        return AddTransactionForm(
          isEmbedded: true,
          onSuccess: () {
            // Form handles reset internally
          },
        );
      case RightPanelMode.quickShop:
        return QuickShoppingForm(
          isEmbedded: true,
          onCancel: onResetRightPanel, // Back to Add Transaction
          onSuccess: () {},
        );
      case RightPanelMode.history:
        // Wrap Daily Details in scroll view for independent scrolling
        return SingleChildScrollView(
          child: dailyExpenseDetails,
        );
      case RightPanelMode.aiChat:
        return const AiChatPanel();
    }
  }
}
