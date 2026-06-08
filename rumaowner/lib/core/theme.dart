import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color cream = Color(0xFFF8F4EC);
  static const Color creamSoft = Color(0xFFFCF8F0);
  static const Color surface = Colors.white;
  static const Color olive = Color(0xFF3A4328);
  static const Color oliveDark = Color(0xFF2F3520);
  static const Color accent = Color(0xFFC56A2B);
  static const Color border = Color(0xFFE7DBC8);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF707070);
  static const Color navBackground = Color(0xFF40411A);
  static const Color navButton = Color(0xFFF0D7A9);

  static const Color darkOlive = olive;
  static const Color lightBeige = cream;
  static const Color cardWhite = surface;
  static const Color textDark = textPrimary;
  static const Color textLight = Colors.white;

  static const Color statusGreenBg = Color(0xFFC7E8D3);
  static const Color statusGreenText = Color(0xFF295433);
  static const Color statusRedBg = Color(0xFFF0CDCF);
  static const Color statusRedText = Color(0xFF6E2E39);
  static const Color statusBlueBg = Color(0xFFD3DFEF);
  static const Color statusBlueText = Color(0xFF2D4F7E);
  static const Color statusYellowBg = Color(0xFFFFF1B8);
  static const Color statusYellowText = Color(0xFF6F5600);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: darkOlive,
      scaffoldBackgroundColor: lightBeige,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkOlive,
        primary: darkOlive,
        secondary: darkOlive,
        surface: surface,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkOlive, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
