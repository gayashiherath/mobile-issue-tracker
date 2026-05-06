import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color.fromARGB(255, 255, 183, 197);
  static const Color primaryPinkText = Color(0xFF431823);

  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primaryPink,
          brightness: brightness,
        ).copyWith(
          primary: primaryPink,
          onPrimary: primaryPinkText,
          secondary: isDark ? const Color(0xFF83D6CE) : const Color(0xFF287B76),
          onSecondary: isDark ? const Color(0xFF062B28) : Colors.white,
          surface: isDark ? const Color(0xFF1D171A) : Colors.white,
        );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark
            ? Colors.white.withValues(alpha: 0.14)
            : const Color(0xFFE8DCE0),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF131012)
          : const Color(0xFFFFF7F9),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPink,
        foregroundColor: primaryPinkText,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF241D21) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: primaryPink, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: primaryPinkText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPink,
        foregroundColor: primaryPinkText,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        textStyle: TextStyle(color: colorScheme.onSurface),
        iconColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFFFFE9EE) : const Color(0xFF33272B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
