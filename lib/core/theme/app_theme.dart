import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color primaryBrown = Color(0xFF5D4037);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFEBEE);

  static const Color lightScaffoldBg = Color(0xFFF5F7F9);
  static const Color lightCardBg = Colors.white;

  static const Color darkScaffoldBg = Color(0xFF121212);
  static const Color darkCardBg = Color(0xFF1E1E1E);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [accentGreen, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color creamColor = Color(0xFFFDF5E6);

  static const Color primaryColor = primaryGreen;
  static const Color secondaryColor = primaryBrown;

  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    error: errorColor,
    errorContainer: errorContainer,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme.copyWith(
        surface: lightCardBg,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: lightScaffoldBg,
      cardColor: lightCardBg,
      textTheme: GoogleFonts.cairoTextTheme(),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
        surface: darkCardBg,
        onSurface: Colors.white,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkScaffoldBg,
      cardColor: darkCardBg,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
