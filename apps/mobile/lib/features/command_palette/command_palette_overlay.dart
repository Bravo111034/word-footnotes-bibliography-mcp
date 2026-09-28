import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';

const _recentCommands = ['Summarize the Q3 board deck', 'Research EV battery supply chains'];
const _suggestedActions = ['Start a new research', 'Create a presentation', 'Ask about a file'];

/// Full-screen command palette (⌘K on desktop, tap the command bar on
/// mobile): a natural-language input plus recent commands and suggested
/// actions (spec §9).
class CommandPaletteOverlay extends StatelessWidget {
  const CommandPaletteOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const CommandPaletteOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 96, left: 24, right: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(AuraSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuraCommandBar(
                autofocus: true,
                onSubmitted: (text) => _openChat(context, text),
              ),
              const SizedBox(height: AuraSpace.lg),
              Text('RECENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.aura.muted, letterSpacing: 1)),
              const SizedBox(height: AuraSpace.xs),
              ..._recentCommands.map((c) => _PaletteRow(icon: Icons.history, label: c, onTap: () => _openChat(context, c))),
              const SizedBox(height: AuraSpace.md),
              Text('SUGGESTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: context.aura.muted, letterSpacing: 1)),
              const SizedBox(height: AuraSpace.xs),
              ..._suggestedActions.map((c) => _PaletteRow(icon: Icons.auto_awesome, label: c, onTap: () => _openChat(context, c))),
            ],
          ),
        ),
      ),
    );
  }

  static void _openChat(BuildContext context, String text) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(initialMessage: text)));
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: context.aura.text2),
      title: Text(label),
      onTap: onTap,
    );
  }
}
