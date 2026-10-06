import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //Verts (Mode Clair)
  static const Color primaryForest = Color(
    0xFF075E4D,
  ); // Vert Forêt Profond (#075E4D)
  static const Color secondaryEmerald = Color(
    0xFF0E8F76,
  ); // Vert Émeraude (#0E8F76)
  static const Color primary = primaryForest;

  //Or & Jaune (Patrimoine & Accents)
  static const Color sahelGold = Color(0xFFD6A23A); // Or Sahélien (#D6A23A)
  static const Color heritageGold = sahelGold;
  static const Color solarYellow = Color(0xFFF2B544); // Jaune Solaire (#F2B544)

  //Arrière-plans & Surfaces (Mode Clair)
  static const Color mistIvory = Color(0xFFF7F8F5); // Ivoire Brumeux (#F7F8F5)
  static const Color pureWhite = Color(0xFFFFFFFF); // Blanc Pur (#FFFFFF)
  static const Color borderLight = Color(0xFFE2E8F0); // Bordure claire

  //Textes (Mode Clair)
  static const Color textPrimary = Color(
    0xFF16332D,
  ); // Vert Anthracite (#16332D)
  static const Color textSecondary = Color(0xFF6C7C77); // Gris Sauge (#6C7C77)
  static const Color textMuted = Color(0xFF94A3B8);

  //MODE SOMBRE
  static const Color darkBackground = Color(0xFF0B1714); // #0B1714
  static const Color darkBackgroundSecondary = Color(0xFF10221E); // #10221E
  static const Color darkSurface = Color(0xFF16332D); // #16332D
  static const Color darkSurfaceElevated = Color(0xFF1C4038); // #1C4038
  static const Color darkBorder = Color(0xFF29453F); // #29453F

  static const Color primaryInteractive = Color(0xFF0E8F76); // #0E8F76

  static const Color darkTextPrimary = Color(0xFFF7F8F5); // #F7F8F5
  static const Color darkTextSecondary = Color(0xFFB7C4BF); // #B7C4BF
  static const Color darkTextDisabled = Color(0xFF71817C); // #71817C

  static const Color darkCard = darkSurface;

  //Accents Culturels & Statuts
  static const Color earthOchre = Color(0xFFB45309);
  static const Color terracotta = Color(0xFFC2410C);
  static const Color indigoMali = Color(0xFF1D4ED8);
  static const Color accentRed = Color(0xFFDC2626);
  static const Color error = Color(0xFFE57373); // #E57373
  static const Color success = Color(0xFF4DB6AC); // #4DB6AC
  static const Color warning = Color(0xFFF59E0B);
}
