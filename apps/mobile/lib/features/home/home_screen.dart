import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import '../catalog/widget_catalog_screen.dart';
import '../command_palette/command_palette_overlay.dart';
import '../notifications/notification_center_screen.dart';

const _quickActions = ['Research', 'Write', 'Create image', 'Summarize'];
const _continueWorking = ['Q3 competitive analysis', 'Blog draft: "Local-first AI"'];
const _activeTasks = ['Publishing weekly newsletter', 'Comparing 3 vendor proposals'];
const _recentWork = ['EV battery report.pdf', 'Brand moodboard', 'Customer interview notes'];

/// Home — AI Command Center: greeting, command bar, quick actions, and
/// activity rows (spec §10).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuraTopBar(
        title: 'Home',
        notificationCount: 1,
        onSearchTap: () => CommandPaletteOverlay.show(context),
        onNotificationsTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
        ),
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WidgetCatalogScreen()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AuraSpace.lg),
        children: [
          Text('Good to see you.', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AuraSpace.lg),
          AuraCommandBar(onTap: () => CommandPaletteOverlay.show(context)),
          const SizedBox(height: AuraSpace.md),
          Wrap(
            spacing: AuraSpace.xs,
            children: _quickActions.map((a) => ActionChip(label: Text(a), onPressed: () {})).toList(),
          ),
          const SizedBox(height: AuraSpace.xl),
          const _SectionHeader('Continue working'),
          ..._continueWorking.map((t) => _RowCard(title: t, icon: Icons.description_outlined)),
          const SizedBox(height: AuraSpace.xl),
          const _SectionHeader('Active tasks'),
          ..._activeTasks.map((t) => _RowCard(title: t, icon: Icons.bolt_outlined, tone: AuraBadgeTone.violet)),
          const SizedBox(height: AuraSpace.xl),
          const _SectionHeader('Recent work'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AuraSpace.sm,
            crossAxisSpacing: AuraSpace.sm,
            childAspectRatio: 2.2,
            children: _recentWork
                .map((w) => AuraCard(child: Center(child: Text(w, textAlign: TextAlign.center))))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpace.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.title, required this.icon, this.tone = AuraBadgeTone.neutral});

  final String title;
  final IconData icon;
  final AuraBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpace.sm),
      child: AuraCard(
        onTap: () {},
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.aura.text2),
            const SizedBox(width: AuraSpace.sm),
            Expanded(child: Text(title)),
            AuraStatusBadge(label: 'IN PROGRESS', tone: tone),
          ],
        ),
      ),
    );
  }
}
