import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';
import '../../pages/ai_chat/ai_chat_page.dart';

import '../../../injection_container.dart' as di;
import '../../../domain/usecases/process_recurring_transactions_usecase.dart';
import '../../../core/responsive_layout.dart';
import '../dashboard_page/dashboard_page.dart';
import '../reports_page/reports_page.dart';
import '../settings_page/settings_page.dart';
import '../transaction_page/transaction_page.dart';
import 'mobile/home_page_mobile.dart';
import 'ipad/home_page_ipad.dart';

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
        Future.delayed(const Duration(milliseconds: 500), () {
          _openAiModal(autoStart: true);
        });
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'add_transaction',
        localizedTitle: 'Thêm giao dịch',
        icon: 'add',
      ),
    ]);
  }

  void _openAiModal({bool autoStart = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiChatPage(autoStartListening: autoStart),
      ),
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

  Widget _buildPageContent() {
    return AnimatedSwitcher(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageContent = _buildPageContent();

    return ResponsiveLayout(
      mobileLayout: HomePageMobile(
        currentIndex: _currentIndex,
        onIndexChanged: (index) => setState(() => _currentIndex = index),
        pageContent: pageContent,
      ),
      tabletLayout: HomePageIpad(
        currentIndex: _currentIndex,
        onIndexChanged: (index) => setState(() => _currentIndex = index),
        pageContent: pageContent,
      ),
    );
  }
}
