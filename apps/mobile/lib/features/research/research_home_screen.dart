import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/research_state.dart';
import 'active_research_screen.dart';

const _depths = ['Quick', 'Standard', 'Deep'];

/// Research Home: a large input plus depth/source/date/language controls
/// and a Start Research button (spec §16).
class ResearchHomeScreen extends ConsumerStatefulWidget {
  const ResearchHomeScreen({super.key});

  @override
  ConsumerState<ResearchHomeScreen> createState() => _ResearchHomeScreenState();
}

class _ResearchHomeScreenState extends ConsumerState<ResearchHomeScreen> {
  final _controller = TextEditingController();
  String _depth = 'Standard';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    ref.read(researchControllerProvider.notifier).startResearch(query);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActiveResearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Research')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AuraSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('What should Aura research?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AuraSpace.md),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. EV battery supply chains in 2026',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AuraSpace.lg),
            Text('Depth', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AuraSpace.xs),
            Wrap(
              spacing: AuraSpace.xs,
              children: _depths
                  .map((d) => ChoiceChip(
                        label: Text(d),
                        selected: _depth == d,
                        onSelected: (_) => setState(() => _depth = d),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AuraSpace.xl),
            FilledButton(
              onPressed: _start,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: AuraSpace.xs),
                child: Text('Start Research'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
