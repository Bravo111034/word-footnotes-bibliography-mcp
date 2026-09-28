import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/image_studio_state.dart';

const _styles = ['Photoreal', 'Illustration', '3D render', 'Sketch'];
const _aspectRatios = ['1:1', '16:9', '9:16', '4:3'];

/// Image Studio: config panel, generation canvas, and a variations history
/// (spec §25). Provider/model selection and real generation are a
/// follow-up — this "generates" color-swatch placeholders so the layout,
/// state, and result actions work end-to-end.
class ImageStudioScreen extends ConsumerStatefulWidget {
  const ImageStudioScreen({super.key});

  @override
  ConsumerState<ImageStudioScreen> createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends ConsumerState<ImageStudioScreen> {
  final _promptController = TextEditingController();
  String _style = _styles.first;
  String _aspectRatio = _aspectRatios.first;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageStudioControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Image Studio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AuraSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Describe the image you want...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AuraSpace.md),
            Text('Style', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AuraSpace.xs),
            Wrap(
              spacing: AuraSpace.xs,
              children: _styles
                  .map((s) => ChoiceChip(label: Text(s), selected: _style == s, onSelected: (_) => setState(() => _style = s)))
                  .toList(),
            ),
            const SizedBox(height: AuraSpace.md),
            Text('Aspect ratio', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AuraSpace.xs),
            Wrap(
              spacing: AuraSpace.xs,
              children: _aspectRatios
                  .map((r) => ChoiceChip(
                        label: Text(r),
                        selected: _aspectRatio == r,
                        onSelected: (_) => setState(() => _aspectRatio = r),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AuraSpace.lg),
            FilledButton(
              onPressed: state.isGenerating ? null : _generate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AuraSpace.xs),
                child: Text(state.isGenerating ? 'Generating...' : 'Generate'),
              ),
            ),
            const SizedBox(height: AuraSpace.xl),
            _Canvas(isGenerating: state.isGenerating, latest: state.variations.isEmpty ? null : state.variations.first),
            if (state.variations.isNotEmpty) ...[
              const SizedBox(height: AuraSpace.lg),
              Text('Variations', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AuraSpace.sm),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.variations.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AuraSpace.sm),
                  itemBuilder: (context, i) => _VariationThumbnail(image: state.variations[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _generate() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;
    ref.read(imageStudioControllerProvider.notifier).generate(prompt);
  }
}

class _Canvas extends StatelessWidget {
  const _Canvas({required this.isGenerating, required this.latest});

  final bool isGenerating;
  final GeneratedImage? latest;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: latest?.seedColor.withValues(alpha: 0.15) ?? context.aura.surface2,
          border: Border.all(color: context.aura.border),
          borderRadius: BorderRadius.circular(AuraRadius.lg),
        ),
        child: Center(
          child: isGenerating
              ? const AuraIntelligenceIndicator(state: AuraState.creating, size: 48)
              : latest == null
                  ? Text('No image yet', style: TextStyle(color: context.aura.text2))
                  : Icon(Icons.image_outlined, size: 48, color: latest!.seedColor),
        ),
      ),
    );
  }
}

class _VariationThumbnail extends StatelessWidget {
  const _VariationThumbnail({required this.image});

  final GeneratedImage image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: image.seedColor.withValues(alpha: 0.15),
        border: Border.all(color: image.seedColor),
        borderRadius: BorderRadius.circular(AuraRadius.md),
      ),
      child: Icon(Icons.image_outlined, color: image.seedColor),
    );
  }
}
