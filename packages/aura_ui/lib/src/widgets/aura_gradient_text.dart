import 'package:flutter/material.dart';

import '../theme/aura_tokens.dart';

/// Renders [text] with the Aura brand gradient painted through its glyphs.
class AuraGradientText extends StatelessWidget {
  const AuraGradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AuraColors.brandGradient,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}
