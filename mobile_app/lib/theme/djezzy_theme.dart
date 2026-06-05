import 'package:flutter/material.dart';

class DjezzyTheme {
  // Les couleurs officielles basées sur ton design
  static const Color primaryRed = Color(0xFFE3000F); // Rouge Djezzy
  static const Color darkText = Color(0xFF2C2C2C);
  static const Color lightText = Color(0xFF757575);
  static const Color background = Color(0xFFF9F0F0); // Arrière plan très légèrement rosé comme sur l'UI
  static const Color white = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryRed,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        secondary: primaryRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
      ),
      // Style global de tous les boutons de l'application
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      // Style global de tous les champs de texte (identifiant, email, mot de passe)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryRed, width: 2.0),
        ),
        labelStyle: const TextStyle(color: lightText),
      ),
    );
  }
}
