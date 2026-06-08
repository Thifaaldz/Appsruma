import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color cream = Color(0xFFF7F0E4);
  static const Color creamSoft = Color(0xFFFCF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color olive = Color(0xFF46461E);
  static const Color oliveDark = Color(0xFF333318);
  static const Color accent = Color(0xFFC56A2B);
  static const Color accentSoft = Color(0xFFF2E0D1);
  static const Color border = Color(0xFFE6D8C3);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textMuted = Color(0xFF9A9A9A);
  static const Color navBackground = Color(0xFF3E401A);
  static const Color navButton = Color(0xFFF0D7A9);

  static const Color darkOlive = olive;
  static const Color lightBeige = cream;
  static const Color cardWhite = surface;
  static const Color textDark = textPrimary;
  static const Color textLight = Colors.white;

  static const Color statusGreenBg = Color(0xFFD7F0DC);
  static const Color statusGreenText = Color(0xFF1E451E);
  static const Color statusRedBg = Color(0xFFF6D9DA);
  static const Color statusRedText = Color(0xFF7D1F25);
  static const Color statusBlueBg = Color(0xFFDDE9F8);
  static const Color statusBlueText = Color(0xFF2D4F7E);
  static const Color statusYellowBg = Color(0xFFFFF1B8);
  static const Color statusYellowText = Color(0xFF6B5A08);
  static const Color statusMintBg = Color(0xFFDDF3E6);
  static const Color statusMintText = Color(0xFF24613B);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
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
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(color: textDark),
        bodyMedium: GoogleFonts.poppins(color: textDark),
        labelLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBeige,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.poppins(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkOlive,
          foregroundColor: textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkOlive, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE4E4E4),
        selectedColor: darkOlive,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
      ),
    );
  }
}
