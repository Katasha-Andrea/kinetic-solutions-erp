import 'package:flutter/material.dart';

class AppTheme {
  // Brand colours
  static const Color primaryColor   = Color(0xFF1B5E20);
  static const Color primary700     = Color(0xFF2E7D32);
  static const Color primary500     = Color(0xFF4CAF50);
  static const Color primary50      = Color(0xFFE8F5E9);
  static const Color accentColor    = Color(0xFFFF9800);
  static const Color accentLight    = Color(0xFFFFF3E0);
  static const Color errorColor     = Color(0xFFE53935);
  static const Color errorLight     = Color(0xFFFFEBEE);
  static const Color warningColor   = Color(0xFFE65100);
  static const Color warningLight   = Color(0xFFFFF3E0);
  static const Color infoColor      = Color(0xFF1565C0);
  static const Color infoLight      = Color(0xFFE3F2FD);
  static const Color purpleColor    = Color(0xFF6A1B9A);
  static const Color purpleLight    = Color(0xFFF3E5F5);

  // Neutrals
  static const Color bgColor        = Color(0xFFF5F7FA);
  static const Color surfaceColor   = Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF1A1A2E);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color textMuted      = Color(0xFF9CA3AF);
  static const Color borderColor    = Color(0xFFE5E7EB);

  static List<BoxShadow> softShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
  ];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: primary500,
      error: errorColor,
      surface: surfaceColor,
    ),
    scaffoldBackgroundColor: bgColor,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    navigationDrawerTheme: const NavigationDrawerThemeData(
      backgroundColor: surfaceColor,
      indicatorColor: primary50,
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(color: borderColor, space: 0, thickness: 0.5),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold,  color: textPrimary),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,  color: textPrimary),
      displaySmall:  TextStyle(fontSize: 22, fontWeight: FontWeight.w600,  color: textPrimary),
      headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,  color: textPrimary),
      headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w600,  color: textPrimary),
      headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,  color: textPrimary),
      titleLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600,  color: textPrimary),
      titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500,  color: textPrimary),
      titleSmall:    TextStyle(fontSize: 13, fontWeight: FontWeight.w500,  color: textPrimary),
      bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.normal,color: textPrimary),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.normal,color: textPrimary),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.normal,color: textSecondary),
      labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w500,  color: textSecondary),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500,  color: textSecondary),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500,  color: textMuted),
    ),
  );
}
