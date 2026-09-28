import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

class _MemoryItem {
  const _MemoryItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const _sections = <String, List<_MemoryItem>>{
  'User': [
    _MemoryItem(title: 'Prefers concise, direct answers', subtitle: 'Learned from 14 conversations'),
  ],
  'Project': [
    _MemoryItem(title: 'EV Battery Market uses APA citations', subtitle: 'Set 2 weeks ago'),
  ],
  'Saved Knowledge': [
    _MemoryItem(title: '"IEA Global EV Outlook 2026" key stats', subtitle: 'Saved from research'),
  ],
  'Preferences': [
    _MemoryItem(title: 'Default model: Balanced', subtitle: 'Settings'),
  ],
};

/// Memory Manager: User / Project / Saved Knowledge / Preferences sections
/// with semantic search (spec §33-34). Search and edit/remove are UI-only
/// until the memory backend lands.
class MemoryManagerScreen extends StatelessWidget {
  const MemoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory')),
      body: ListView(
        padding: const EdgeInsets.all(AuraSpace.md),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search everything Aura remembers',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AuraSpace.lg),
          for (final entry in _sections.entries) ...[
            Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AuraSpace.sm),
            ...entry.value.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AuraSpace.sm),
                child: AuraCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title),
                            const SizedBox(height: AuraSpace.xxs),
                            Text(item.subtitle, style: TextStyle(fontSize: 12, color: context.aura.text2)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () {}),
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
