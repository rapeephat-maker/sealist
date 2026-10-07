import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Text styles that need a specific font family.
///
/// Body text does not need anything here: it inherits Sarabun from the theme.
/// Use [AppText.heading] for titles, greetings and buttons — it gives the
/// cute rounded Mali look (which also has full Thai glyphs).
class AppText {
  AppText._();

  static TextStyle heading({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.darkText,
    double height = 1.35,
  }) {
    return GoogleFonts.mali(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }
}
