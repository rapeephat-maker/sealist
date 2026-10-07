import 'package:flutter/material.dart';

/// SeaList ocean-inspired palette.
/// Kept as one place so every screen pulls from the same calm set of colors.
class AppColors {
  AppColors._();

  // Ocean core
  static const deepOcean = Color(0xFF075985);
  static const oceanBlue = Color(0xFF0284C7);
  static const turquoise = Color(0xFF14B8A6);
  static const seafoam = Color(0xFFCCFBF1);
  static const sky = Color(0xFFE0F2FE);
  static const softWhite = Color(0xFFF5FAFC);
  static const darkText = Color(0xFF164E63);
  static const mutedText = Color(0xFF64748B);
  static const faintText = Color(0xFFA3B6BD);

  // Cute pastel accents (used sparingly for warmth)
  static const coral = Color(0xFFFF8FA3);
  static const coralSoft = Color(0xFFFFE4EA);
  static const sunny = Color(0xFFFFC94D);
  static const sunnySoft = Color(0xFFFFF3CC);
  static const lavender = Color(0xFF9F8CFF);
  static const lavenderSoft = Color(0xFFECE8FF);

  // Supporting tones (overdue warmth, priority chips)
  static const overdue = Color(0xFFB45309);
  static const danger = Color(0xFFB91C1C);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const priorityLowBg = Color(0xFFE0F2FE);
  static const priorityMedBg = Color(0xFFFEF9C3);
  static const priorityHighBg = Color(0xFFFEE2E2);
  static const cardBorder = Color(0xFFE2EDF0);

  /// Sticky-note tints for the notes list — picked per note so the list
  /// feels like a little board of pastel notes.
  static const noteTints = <Color>[
    Color(0xFFE0F2FE),
    Color(0xFFCCFBF1),
    Color(0xFFFFE4EA),
    Color(0xFFFFF3CC),
    Color(0xFFECE8FF),
  ];
}
