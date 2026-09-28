import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import 'publishing_workflow_drawer.dart';

class _Content {
  const _Content({required this.title, required this.platform});

  final String title;
  final String platform;
}

const _tabs = ['Drafts', 'Approved', 'Scheduled', 'Published', 'Failed'];

const _initialContentByTab = <String, List<_Content>>{
  'Drafts': [_Content(title: 'Q3 recap carousel', platform: 'LinkedIn')],
  'Approved': [_Content(title: 'Battery report summary', platform: 'X')],
  'Scheduled': [_Content(title: 'Monday newsletter', platform: 'Email')],
  'Published': [_Content(title: 'Weekly digest #14', platform: 'Blog')],
  'Failed': [_Content(title: 'Product update thread', platform: 'X')],
};

/// Publishing Hub: Drafts / Approved / Scheduled / Published / Failed tabs
/// with content cards (spec §35-38). Tapping a Draft opens the full
/// [PublishingWorkflowDrawer]; tapping an Approved item publishes it
/// directly. Both end in a real, consequential, public action, so both are
/// gated behind a permission confirmation (spec §44). The calendar view is
/// a follow-up.
class PublishingHubScreen extends StatefulWidget {
  const PublishingHubScreen({super.key});

  @override
  State<PublishingHubScreen> createState() => _PublishingHubScreenState();
}

class _PublishingHubScreenState extends State<PublishingHubScreen> {
  final _contentByTab = {for (final e in _initialContentByTab.entries) e.key: List<_Content>.from(e.value)};

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Publishing'),
          bottom: TabBar(isScrollable: true, tabs: _tabs.map((t) => Tab(text: t)).toList()),
        ),
        body: TabBarView(
          children: _tabs.map((tab) {
            final items = _contentByTab[tab] ?? const [];
            if (items.isEmpty) {
              return Center(child: Text('No $tab content', style: TextStyle(color: context.aura.text2)));
            }
            final tone = switch (tab) {
              'Published' => AuraBadgeTone.success,
              'Failed' => AuraBadgeTone.error,
              'Scheduled' => AuraBadgeTone.warning,
              _ => AuraBadgeTone.neutral,
            };
            return ListView.separated(
              padding: const EdgeInsets.all(AuraSpace.md),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AuraSpace.sm),
              itemBuilder: (context, i) {
                final item = items[i];
                return AuraCard(
                  onTap: tab == 'Approved'
                      ? () => _confirmPublish(item)
                      : tab == 'Drafts'
                          ? () => _runWorkflow(item)
                          : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: AuraSpace.xxs),
                            Text(item.platform, style: TextStyle(fontSize: 12, color: context.aura.text2)),
                          ],
                        ),
                      ),
                      AuraStatusBadge(label: tab.toUpperCase(), tone: tone),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _confirmPublish(_Content item) async {
    final confirmed = await AuraPermissionDialog.confirm(
      context,
      title: 'Publish publicly?',
      description: '"${item.title}" will go live on ${item.platform} for anyone to see.',
      confirmLabel: 'Publish',
    );
    if (confirmed) {
      setState(() {
        _contentByTab['Approved']!.remove(item);
        _contentByTab['Published']!.insert(0, item);
      });
    }
  }

  Future<void> _runWorkflow(_Content item) async {
    final completed = await PublishingWorkflowDrawer.show(context);
    if (completed && mounted) {
      setState(() {
        _contentByTab['Drafts']!.remove(item);
        _contentByTab['Published']!.insert(0, item);
      });
    }
  }
}
