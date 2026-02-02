import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class ThemeState extends Equatable {
  final Color primaryColor;
  final bool isDark;

  const ThemeState({
    required this.primaryColor,
    this.isDark = false,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      primaryColor: AppColors.primaryBlue,
      isDark: false,
    );
  }

  ThemeState copyWith({
    Color? primaryColor,
    bool? isDark,
  }) {
    return ThemeState(
      primaryColor: primaryColor ?? this.primaryColor,
      isDark: isDark ?? this.isDark,
    );
  }

  /// Generate ThemeData based on current state
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: isDark ? Colors.grey[900] : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }

  @override
  List<Object?> get props => [primaryColor, isDark];
}
