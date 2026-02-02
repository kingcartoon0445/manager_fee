import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';
import '../../../core/app_colors.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences prefs;

  static const String _themeColorKey = 'theme_primary_color';
  static const String _isDarkModeKey = 'theme_is_dark';

  ThemeCubit(this.prefs) : super(ThemeState.initial()) {
    loadSavedTheme();
  }

  /// Load saved theme from SharedPreferences
  Future<void> loadSavedTheme() async {
    try {
      final colorValue = prefs.getInt(_themeColorKey);
      final isDark = prefs.getBool(_isDarkModeKey) ?? false;

      if (colorValue != null) {
        emit(ThemeState(
          primaryColor: Color(colorValue),
          isDark: isDark,
        ));
      }
    } catch (e) {
      print('Error loading theme: $e');
      // Keep default theme
    }
  }

  /// Change primary color
  Future<void> changeColor(Color color) async {
    try {
      await prefs.setInt(_themeColorKey, color.value);
      emit(state.copyWith(primaryColor: color));
    } catch (e) {
      print('Error saving theme color: $e');
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    try {
      final newDarkMode = !state.isDark;
      await prefs.setBool(_isDarkModeKey, newDarkMode);
      emit(state.copyWith(isDark: newDarkMode));
    } catch (e) {
      print('Error toggling dark mode: $e');
    }
  }

  /// Reset to default theme
  Future<void> resetToDefault() async {
    try {
      await prefs.remove(_themeColorKey);
      await prefs.remove(_isDarkModeKey);
      emit(ThemeState.initial());
    } catch (e) {
      print('Error resetting theme: $e');
    }
  }

  /// Predefined theme colors
  static const List<Color> themeColors = [
    AppColors.primaryBlue, // Default Blue
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFF44336), // Red
    Color(0xFF795548), // Brown
  ];
}
