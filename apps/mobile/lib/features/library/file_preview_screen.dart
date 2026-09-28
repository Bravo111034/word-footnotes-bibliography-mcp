import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';
import 'library_screen.dart';

/// File preview with an "Ask Aura" quick action that opens Chat seeded
/// with a prompt about the file (spec §30-32). The actual preview
/// rendering (PDF/image/doc viewers) is a follow-up.
class FilePreviewScreen extends StatelessWidget {
  const FilePreviewScreen({super.key, required this.file});

  final LibraryFile file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(file.name, overflow: TextOverflow.ellipsis)),
      body: Padding(
        padding: const EdgeInsets.all(AuraSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(file.icon, size: 64, color: AuraColors.violet),
                    const SizedBox(height: AuraSpace.md),
                    Text(file.name, textAlign: TextAlign.center),
                    const SizedBox(height: AuraSpace.xs),
                    if (file.aiProcessed)
                      const AuraStatusBadge(label: 'AI PROCESSED', tone: AuraBadgeTone.violet),
                  ],
                ),
              ),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Ask Aura about this file'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatScreen(initialMessage: 'Tell me about "${file.name}"')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
