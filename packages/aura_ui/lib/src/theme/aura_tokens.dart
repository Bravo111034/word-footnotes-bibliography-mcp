import 'package:flutter/material.dart';

/// Aura brand color tokens. Values mirror the roadmap's light/dark palette
/// so every screen and widget pulls from one source of truth.
class AuraColors {
  AuraColors._();

  // Light
  static const Color bgLight = Color(0xFFF7F8FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF1F3F8);
  static const Color borderLight = Color(0xFFE1E5ED);
  static const Color textLight = Color(0xFF171A21);
  static const Color text2Light = Color(0xFF667085);

  // Dark
  static const Color bgDark = Color(0xFF080B12);
  static const Color surfaceDark = Color(0xFF0E1320);
  static const Color surface2Dark = Color(0xFF151B2B);
  static const Color borderDark = Color(0xFF252D40);
  static const Color textDark = Color(0xFFF5F7FB);
  static const Color text2Dark = Color(0xFFA2ABBD);

  // Shared accents
  static const Color muted = Color(0xFF94A3B8);
  static const Color violet = Color(0xFF7C5CFC);
  static const Color indigo = Color(0xFF6366F1);
  static const Color cyan = Color(0xFF27C8E8);
  static const Color success = Color(0xFF35C98B);
  static const Color warning = Color(0xFFF4B740);
  static const Color error = Color(0xFFF06464);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet, indigo, cyan],
  );
}

/// Spacing scale, 4px base unit.
class AuraSpace {
  AuraSpace._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Corner radius scale.
class AuraRadius {
  AuraRadius._();

  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;
}

/// Motion durations and curves for consistent UI feel across the app.
class AuraMotion {
  AuraMotion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration ui = Duration(milliseconds: 200);
  static const Duration panel = Duration(milliseconds: 300);
  static const Duration breathing = Duration(milliseconds: 2200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
}
