import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

class _MemoryItem {
  const _MemoryItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const _initialSections = <String, List<_MemoryItem>>{
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
/// with semantic search (spec §33-34). Search and edit are UI-only until
/// the memory backend lands; delete is real (in local state) and gated
/// behind a permission confirmation (spec §44), since forgetting something
/// is a consequential, hard-to-undo action.
class MemoryManagerScreen extends StatefulWidget {
  const MemoryManagerScreen({super.key});

  @override
  State<MemoryManagerScreen> createState() => _MemoryManagerScreenState();
}

class _MemoryManagerScreenState extends State<MemoryManagerScreen> {
  final _sections = {for (final e in _initialSections.entries) e.key: List<_MemoryItem>.from(e.value)};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memory')),
      body: ListView(
        padding: const EdgeInsets.all(AuraSpace.md),
        children: [
          const TextField(
            decoration: InputDecoration(
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
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _confirmDelete(entry.key, item),
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

  Future<void> _confirmDelete(String section, _MemoryItem item) async {
    final confirmed = await AuraPermissionDialog.confirm(
      context,
      title: 'Forget this?',
      description: 'Aura will stop remembering: "${item.title}". This cannot be undone.',
      confirmLabel: 'Forget',
      destructive: true,
    );
    if (confirmed) {
      setState(() => _sections[section]!.remove(item));
    }
  }
}
