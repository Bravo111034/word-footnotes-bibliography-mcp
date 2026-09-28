import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import '../analytics/analytics_screen.dart';
import '../catalog/widget_catalog_screen.dart';
import '../integrations/integrations_screen.dart';
import '../publishing/publishing_hub_screen.dart';
import '../settings/settings_screen.dart';

class _MoreEntry {
  const _MoreEntry(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

final _entries = [
  _MoreEntry('Publishing', Icons.send_outlined, (_) => const PublishingHubScreen()),
  _MoreEntry('Analytics', Icons.insights_outlined, (_) => const AnalyticsScreen()),
  _MoreEntry('Integrations', Icons.extension_outlined, (_) => const IntegrationsScreen()),
  _MoreEntry('Settings', Icons.settings_outlined, (_) => const SettingsScreen()),
  _MoreEntry('Widget catalog (dev)', Icons.widgets_outlined, (_) => const WidgetCatalogScreen()),
];

/// The mobile "More" sheet (spec §46) — everything that doesn't fit in the
/// bottom nav's 5 primary destinations.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        itemCount: _entries.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: context.aura.border),
        itemBuilder: (context, i) {
          final entry = _entries[i];
          return ListTile(
            leading: Icon(entry.icon, size: 20),
            title: Text(entry.label),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: entry.builder)),
          );
        },
      ),
    );
  }
}
