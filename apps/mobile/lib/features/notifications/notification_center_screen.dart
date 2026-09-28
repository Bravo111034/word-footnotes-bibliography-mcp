import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

class _NotificationItem {
  const _NotificationItem({required this.title, required this.subtitle, required this.tone});

  final String title;
  final String subtitle;
  final AuraBadgeTone tone;
}

const _categories = ['Task', 'Research', 'Generation', 'Publish', 'Integration'];

const _mockItems = <String, List<_NotificationItem>>{
  'Task': [
    _NotificationItem(title: 'Weekly report task finished', subtitle: '2 min ago', tone: AuraBadgeTone.success),
  ],
  'Research': [
    _NotificationItem(title: 'Deep research complete: "EV battery supply chains"', subtitle: '18 min ago', tone: AuraBadgeTone.violet),
  ],
  'Generation': [
    _NotificationItem(title: 'Image variations ready', subtitle: '1 hr ago', tone: AuraBadgeTone.neutral),
  ],
  'Publish': [
    _NotificationItem(title: 'Post failed to publish to LinkedIn', subtitle: '3 hr ago', tone: AuraBadgeTone.error),
  ],
  'Integration': [
    _NotificationItem(title: 'Google Drive connected', subtitle: 'Yesterday', tone: AuraBadgeTone.success),
  ],
};

/// Notification Center with category tabs (spec §45). Data is mocked until
/// a real notifications backend lands.
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          bottom: TabBar(isScrollable: true, tabs: _categories.map((c) => Tab(text: c)).toList()),
        ),
        body: TabBarView(
          children: _categories.map((category) {
            final items = _mockItems[category] ?? const [];
            if (items.isEmpty) {
              return Center(child: Text('No $category notifications', style: TextStyle(color: context.aura.text2)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AuraSpace.md),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AuraSpace.sm),
              itemBuilder: (context, i) {
                final item = items[i];
                return AuraCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: AuraSpace.xxs),
                            Text(item.subtitle, style: TextStyle(fontSize: 12, color: context.aura.text2)),
                          ],
                        ),
                      ),
                      AuraStatusBadge(label: category.toUpperCase(), tone: item.tone),
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
}
