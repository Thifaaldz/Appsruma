import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors based on the designs
  static const Color darkOlive = Color(0xFF3A4328);
  static const Color lightBeige = Color(0xFFF8F4EC);
  static const Color cardWhite = Colors.white;
  static const Color textDark = Colors.black;
  static const Color textLight = Colors.white;

  // Status Badge Colors
  static const Color statusGreenBg = Color(0xFFC7E8D3);
  static const Color statusGreenText = Colors.black;
  static const Color statusRedBg = Color(0xFFF0CDCF);
  static const Color statusRedText = Colors.black;
  static const Color statusBlueBg = Color(0xFFD3DFEF);
  static const Color statusBlueText = Colors.black;

  static ThemeData get theme {
    return ThemeData(
      primaryColor: darkOlive,
      scaffoldBackgroundColor: lightBeige,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkOlive,
        primary: darkOlive,
        secondary: darkOlive,
        background: lightBeige,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.poppins(color: textDark, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.poppins(color: textDark),
        bodyMedium: GoogleFonts.poppins(color: textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBeige,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.poppins(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkOlive,
          foregroundColor: textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkOlive, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
