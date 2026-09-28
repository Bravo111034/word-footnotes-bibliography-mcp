import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

class _Integration {
  const _Integration({required this.name, required this.connected});

  final String name;
  final bool connected;
}

const _categories = <String, List<_Integration>>{
  'AI Models': [
    _Integration(name: 'Anthropic', connected: true),
    _Integration(name: 'OpenAI', connected: true),
    _Integration(name: 'Google Gemini', connected: false),
  ],
  'Google': [
    _Integration(name: 'Google Drive', connected: true),
    _Integration(name: 'Google Calendar', connected: false),
  ],
  'Publishing': [
    _Integration(name: 'LinkedIn', connected: false),
    _Integration(name: 'X', connected: false),
  ],
  'Storage': [_Integration(name: 'Dropbox', connected: false)],
};

/// Integrations: category sections with OAuth-style connect status pills
/// (spec §40-41). Connecting is UI-only until OAuth flows are wired in.
class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integrations')),
      body: ListView(
        padding: const EdgeInsets.all(AuraSpace.md),
        children: [
          for (final entry in _categories.entries) ...[
            Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AuraSpace.sm),
            ...entry.value.map(
              (integration) => Padding(
                padding: const EdgeInsets.only(bottom: AuraSpace.sm),
                child: AuraCard(
                  child: Row(
                    children: [
                      Expanded(child: Text(integration.name)),
                      AuraStatusBadge(
                        label: integration.connected ? 'CONNECTED' : 'CONNECT',
                        tone: integration.connected ? AuraBadgeTone.success : AuraBadgeTone.neutral,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AuraSpace.md),
          ],
        ],
      ),
    );
  }
}
