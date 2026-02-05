import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import '../widgets/ai_input_modal.dart';

import '../../injection_container.dart' as di;
import '../../domain/usecases/process_recurring_transactions_usecase.dart';
import 'dashboard_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const TransactionPage(),
    const ReportsPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _runAutomation();
    _initQuickActions();
  }

  void _initQuickActions() {
    const QuickActions quickActions = QuickActions();

    quickActions.initialize((shortcutType) {
      if (shortcutType == 'add_transaction') {
        // Wait for UI to be ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _openAiModal(autoStart: true);
        });
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'add_transaction',
        localizedTitle: 'Thêm giao dịch',
        icon:
            'add', // Ensure 'add' icon exists in android/app/src/main/res/drawable or Assets.xcassets
      ),
    ]);
  }

  void _openAiModal({bool autoStart = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiInputModal(autoStartListening: autoStart),
    );
  }

  void _runAutomation() async {
    try {
      final usecase = di.sl<ProcessRecurringTransactionsUseCase>();
      await usecase();
    } catch (e) {
      print("Automation failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.blue, // Primary color
              color: Colors.grey[600], // Inactive color
              tabs: const [
                GButton(
                  icon: Icons.home_outlined,
                  text: 'Tổng quan',
                ),
                GButton(
                  icon: Icons.list_alt_outlined,
                  text: 'Giao dịch',
                ),
                GButton(
                  icon: Icons.pie_chart_outline,
                  text: 'Báo cáo',
                ),
                GButton(
                  icon: Icons.settings_outlined,
                  text: 'Cài đặt',
                ),
              ],
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
