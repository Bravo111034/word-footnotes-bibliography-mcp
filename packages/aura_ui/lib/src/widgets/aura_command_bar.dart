import 'package:flutter/material.dart';

import '../theme/aura_theme.dart';
import '../theme/aura_tokens.dart';
import 'aura_intelligence_indicator.dart';

/// The large "ask Aura anything" input used on Home and inside the global
/// command palette. Tapping it (when [onTap] is set) opens the palette;
/// otherwise it behaves as a live text field via [controller]/[onSubmitted].
class AuraCommandBar extends StatelessWidget {
  const AuraCommandBar({
    super.key,
    this.hintText = 'Ask Aura anything...',
    this.controller,
    this.onTap,
    this.onSubmitted,
    this.autofocus = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final aura = context.aura;

    final field = TextField(
      controller: controller,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      readOnly: onTap != null,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: aura.text2),
        border: InputBorder.none,
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AuraRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.xl),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AuraSpace.lg, vertical: AuraSpace.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: aura.border),
            borderRadius: BorderRadius.circular(AuraRadius.xl),
          ),
          child: Row(
            children: [
              const AuraIntelligenceIndicator(state: AuraState.idle, size: 24),
              const SizedBox(width: AuraSpace.sm),
              Expanded(child: IgnorePointer(ignoring: onTap != null, child: field)),
            ],
          ),
        ),
      ),
    );
  }
}
