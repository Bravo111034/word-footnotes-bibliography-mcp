import 'package:flutter/material.dart';

import '../theme/aura_theme.dart';

/// Wraps [child] with the standard Aura hairline border, without the card
/// background or padding — use inside a component that already has its own
/// surface color.
class AuraBorder extends StatelessWidget {
  const AuraBorder({
    super.key,
    required this.child,
    this.radius = 12,
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.aura.border),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
