import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de Cores Premium (conforme imagem)
  static const Color vinho = Color(0xFF5C162E);
  static const Color verdeEscuro = Color(0xFF1B4332);
  static const Color dourado = Color(0xFFC19A6B);
  static const Color creme = Color(0xFFFDFBF7);
  static const Color pretoSuave = Color(0xFF1A1A1A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: vinho,
        primary: vinho,
        secondary: verdeEscuro,
        tertiary: dourado,
        background: creme,
        onBackground: pretoSuave,
      ),
      scaffoldBackgroundColor: creme,
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: vinho,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: vinho,
        ),
        titleLarge: GoogleFonts.cormorantGaramond(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: dourado,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          color: pretoSuave,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          color: pretoSuave.withOpacity(0.8),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: vinho,
        foregroundColor: dourado,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: dourado),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verdeEscuro,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
