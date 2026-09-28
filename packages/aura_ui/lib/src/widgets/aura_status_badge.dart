import 'package:flutter/material.dart';

import '../theme/aura_theme.dart';
import '../theme/aura_tokens.dart';

enum AuraBadgeTone { neutral, violet, success, warning, error }

/// A small pill badge used for statuses, tags, and counts.
class AuraStatusBadge extends StatelessWidget {
  const AuraStatusBadge({
    super.key,
    required this.label,
    this.tone = AuraBadgeTone.neutral,
  });

  final String label;
  final AuraBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final aura = context.aura;
    final (bg, fg) = switch (tone) {
      AuraBadgeTone.neutral => (aura.surface2, aura.text2),
      AuraBadgeTone.violet => (AuraColors.violet.withValues(alpha: 0.12), AuraColors.violet),
      AuraBadgeTone.success => (AuraColors.success.withValues(alpha: 0.12), AuraColors.success),
      AuraBadgeTone.warning => (AuraColors.warning.withValues(alpha: 0.12), AuraColors.warning),
      AuraBadgeTone.error => (AuraColors.error.withValues(alpha: 0.12), AuraColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AuraRadius.pill)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    );
  }
}
