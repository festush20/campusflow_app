import 'package:flutter/material.dart';

class AppTheme {
  static const Color graine = Color(0xFFEC3013);

  static ThemeData clair() {
    final couleurs = ColorScheme.fromSeed(seedColor: graine);
    return ThemeData(
      useMaterial3: true,
      colorScheme: couleurs,
      // Fond très légèrement teinté pour faire ressortir les cartes.
      scaffoldBackgroundColor:
      Color.alphaBlend(couleurs.primary.withAlpha(10), couleurs.surface),
      // Typographie : poids et espacement des titres.
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        labelLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: couleurs.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: couleurs.surface,
        indicatorColor: couleurs.primaryContainer,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48), // cible tactile de 48 dp
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: const ChipThemeData(shape: StadiumBorder()),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}