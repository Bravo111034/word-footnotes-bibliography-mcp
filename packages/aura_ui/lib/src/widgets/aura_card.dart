import 'package:flutter/material.dart';

import '../theme/aura_theme.dart';
import '../theme/aura_tokens.dart';

/// Standard bordered surface card used throughout Aura screens.
class AuraCard extends StatelessWidget {
  const AuraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AuraSpace.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final aura = context.aura;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: aura.border),
        borderRadius: BorderRadius.circular(AuraRadius.lg),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AuraRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadius.lg),
        child: card,
      ),
    );
  }
}
