import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.oceanBlue,
        primary: AppColors.oceanBlue,
        secondary: AppColors.turquoise,
        surface: AppColors.softWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.softWhite,
    );

    // Sarabun for body (clean Thai + Latin), Mali for the cute headings.
    final bodyFont = GoogleFonts.sarabunTextTheme(base.textTheme);
    final headingFont = GoogleFonts.maliTextTheme(base.textTheme);

    final textTheme = bodyFont.copyWith(
      headlineSmall: headingFont.headlineSmall?.copyWith(
        color: AppColors.darkText,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: headingFont.titleLarge?.copyWith(
        color: AppColors.darkText,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: headingFont.titleMedium?.copyWith(
        color: AppColors.darkText,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(color: AppColors.darkText),
      bodyMedium: bodyFont.bodyMedium?.copyWith(color: AppColors.darkText),
      bodySmall: bodyFont.bodySmall?.copyWith(color: AppColors.mutedText),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.darkText,
        centerTitle: false,
        titleTextStyle: AppText.heading(size: 19),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.turquoise, width: 1.6),
        ),
        hintStyle: const TextStyle(color: AppColors.faintText),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.turquoise,
        selectionHandleColor: AppColors.turquoise,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.oceanBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: AppText.heading(size: 15, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.cardBorder, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: AppText.heading(size: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.oceanBlue,
          textStyle: AppText.heading(size: 14, color: AppColors.oceanBlue),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.oceanBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.turquoise
              : const Color(0xFFDFE9EC),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFEEF3F5), thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titleTextStyle: AppText.heading(size: 18),
        contentTextStyle: const TextStyle(
          fontSize: 14.5,
          color: AppColors.mutedText,
          height: 1.6,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deepOcean,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
    );
  }
}
