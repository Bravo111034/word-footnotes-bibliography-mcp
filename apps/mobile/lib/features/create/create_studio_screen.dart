import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';
import '../image_studio/image_studio_screen.dart';

class _Category {
  const _Category(this.label, this.icon);

  final String label;
  final IconData icon;
}

const _categories = [
  _Category('Writing', Icons.edit_note),
  _Category('Image', Icons.image_outlined),
  _Category('Video', Icons.videocam_outlined),
  _Category('Presentation', Icons.slideshow_outlined),
  _Category('Voice', Icons.mic_none),
  _Category('Document', Icons.description_outlined),
  _Category('Chart', Icons.bar_chart_outlined),
  _Category('Diagram', Icons.account_tree_outlined),
  _Category('Infographic', Icons.insights_outlined),
  _Category('Social', Icons.share_outlined),
  _Category('Web Article', Icons.article_outlined),
];

/// Create Studio: a hero input plus a category grid (spec §23). "Image"
/// opens the dedicated Image Studio; every other category routes into
/// Chat with a seeded prompt until its own studio exists.
class CreateStudioScreen extends StatelessWidget {
  const CreateStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create')),
      body: Padding(
        padding: const EdgeInsets.all(AuraSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('What do you want to create?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AuraSpace.lg),
            AuraCommandBar(
              hintText: 'Describe what you want to create...',
              onSubmitted: (text) => _open(context, text),
            ),
            const SizedBox(height: AuraSpace.xl),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AuraSpace.sm,
                crossAxisSpacing: AuraSpace.sm,
                childAspectRatio: 2.4,
                children: _categories.map((c) {
                  return AuraCard(
                    onTap: () => c.label == 'Image'
                        ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImageStudioScreen()))
                        : _open(context, 'Create a ${c.label.toLowerCase()}'),
                    child: Row(
                      children: [
                        Icon(c.icon, color: AuraColors.violet, size: 20),
                        const SizedBox(width: AuraSpace.sm),
                        Text(c.label),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String prompt) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatScreen(initialMessage: prompt)));
  }
}
