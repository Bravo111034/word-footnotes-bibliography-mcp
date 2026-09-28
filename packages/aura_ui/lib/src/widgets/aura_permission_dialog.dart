import 'package:flutter/material.dart';

import '../theme/aura_theme.dart';
import '../theme/aura_tokens.dart';

/// A confirmation dialog for consequential agent actions (spec §44):
/// publishing publicly, deleting content, sending communications, or
/// stopping a running task. Visually distinct from an ordinary dialog so
/// these moments read differently from routine confirmations.
class AuraPermissionDialog extends StatelessWidget {
  const AuraPermissionDialog({
    super.key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Confirm',
    this.destructive = false,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final bool destructive;

  /// Shows the dialog and returns true only if the user explicitly
  /// confirmed. Dismissing (tap outside, back button) counts as false.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String description,
    String confirmLabel = 'Confirm',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AuraPermissionDialog(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AuraColors.error : AuraColors.warning;

    return AlertDialog(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(destructive ? Icons.warning_amber_rounded : Icons.shield_outlined, color: accent),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(description, textAlign: TextAlign.center, style: TextStyle(color: context.aura.text2)),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive ? FilledButton.styleFrom(backgroundColor: AuraColors.error) : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
