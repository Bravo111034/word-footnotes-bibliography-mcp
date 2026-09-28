import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import '../integrations/integrations_screen.dart';
import 'settings_detail_screen.dart';

const _categories = [
  'General',
  'Appearance',
  'AI & Models',
  'Research',
  'Memory',
  'Tasks & Agents',
  'Notifications',
  'Connected Apps',
  'Privacy',
  'Security',
  'Billing',
  'Advanced',
];

/// Settings: the category list (spec §42-43). "Connected Apps" opens the
/// full Integrations screen; every other category opens a placeholder
/// detail until its controls are built.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        itemCount: _categories.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: context.aura.border),
        itemBuilder: (context, i) {
          final category = _categories[i];
          return ListTile(
            title: Text(category),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => category == 'Connected Apps'
                    ? const IntegrationsScreen()
                    : SettingsDetailScreen(category: category),
              ),
            ),
          );
        },
      ),
    );
  }
}
