import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFFE91E63); // Pink
  static const _secondaryColor = Color(0xFF9C27B0); // Purple
  
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _secondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
  
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      secondary: _secondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
  );
  
  // Risk tier colors
  static const riskHigh = Color(0xFFE53935);
  static const riskMedium = Color(0xFFFF9800);
  static const riskLow = Color(0xFF4CAF50);
  
  static Color riskColor(String? tier) {
    switch (tier?.toLowerCase()) {
      case 'high': return riskHigh;
      case 'medium': return riskMedium;
      case 'low': return riskLow;
      default: return Colors.grey;
    }
  }
  
  // Vital danger level colors
  static const dangerColor = Color(0xFFE53935);
  static const warningColor = Color(0xFFFF9800);
  static const normalColor = Color(0xFF4CAF50);
  
  static Color dangerLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'danger': return dangerColor;
      case 'warning': return warningColor;
      default: return normalColor;
    }
  }
}
