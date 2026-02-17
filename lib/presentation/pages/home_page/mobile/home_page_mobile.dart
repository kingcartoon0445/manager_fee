import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePageMobile extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget pageContent;

  const HomePageMobile({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.pageContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageContent,
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
              tabBackgroundColor: Colors.blue,
              color: Colors.grey[600],
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
              selectedIndex: currentIndex,
              onTabChange: onIndexChanged,
            ),
          ),
        ),
      ),
    );
  }
}
