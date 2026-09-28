import 'package:flutter/material.dart';

import 'aura_tokens.dart';

/// Light and dark [ThemeData] built entirely from [AuraColors] tokens.
class AuraTheme {
  AuraTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AuraColors.bgLight,
        surface: AuraColors.surfaceLight,
        surface2: AuraColors.surface2Light,
        border: AuraColors.borderLight,
        text: AuraColors.textLight,
        text2: AuraColors.text2Light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AuraColors.bgDark,
        surface: AuraColors.surfaceDark,
        surface2: AuraColors.surface2Dark,
        border: AuraColors.borderDark,
        text: AuraColors.textDark,
        text2: AuraColors.text2Dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color surface2,
    required Color border,
    required Color text,
    required Color text2,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AuraColors.violet,
      onPrimary: Colors.white,
      secondary: AuraColors.indigo,
      onSecondary: Colors.white,
      error: AuraColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Inter',
      dividerColor: border,
      cardColor: surface,
      textTheme: Typography.material2021(platform: TargetPlatform.iOS)
          .black
          .apply(bodyColor: text, displayColor: text),
      extensions: [
        AuraThemeExtension(
          surface2: surface2,
          border: border,
          text2: text2,
          muted: AuraColors.muted,
        ),
      ],
    );
  }
}

/// Extra Aura-specific colors not modeled by Material's [ColorScheme].
class AuraThemeExtension extends ThemeExtension<AuraThemeExtension> {
  const AuraThemeExtension({
    required this.surface2,
    required this.border,
    required this.text2,
    required this.muted,
  });

  final Color surface2;
  final Color border;
  final Color text2;
  final Color muted;

  @override
  AuraThemeExtension copyWith({
    Color? surface2,
    Color? border,
    Color? text2,
    Color? muted,
  }) {
    return AuraThemeExtension(
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      text2: text2 ?? this.text2,
      muted: muted ?? this.muted,
    );
  }

  @override
  AuraThemeExtension lerp(ThemeExtension<AuraThemeExtension>? other, double t) {
    if (other is! AuraThemeExtension) return this;
    return AuraThemeExtension(
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

extension AuraThemeContext on BuildContext {
  AuraThemeExtension get aura =>
      Theme.of(this).extension<AuraThemeExtension>()!;
}
