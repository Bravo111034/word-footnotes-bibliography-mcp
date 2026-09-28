import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/research_state.dart';

/// Active Research: the desktop spec (§17-18) lays this out as 3 columns —
/// Plan | Live Report | Sources; on mobile that becomes tabs over the same
/// [ResearchState].
class ActiveResearchScreen extends ConsumerWidget {
  const ActiveResearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final research = ref.watch(researchControllerProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(research.query.isEmpty ? 'Research' : research.query, overflow: TextOverflow.ellipsis),
          bottom: const TabBar(tabs: [Tab(text: 'Plan'), Tab(text: 'Report'), Tab(text: 'Sources')]),
        ),
        body: TabBarView(
          children: [
            _PlanTab(research: research),
            _ReportTab(research: research),
            _SourcesTab(research: research),
          ],
        ),
      ),
    );
  }
}

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.research});

  final ResearchState research;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AuraSpace.md),
      itemCount: research.steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: AuraSpace.sm),
      itemBuilder: (context, i) {
        final step = research.steps[i];
        return Row(
          children: [
            Icon(
              step.done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: step.done ? AuraColors.success : context.aura.muted,
            ),
            const SizedBox(width: AuraSpace.sm),
            Text(step.label),
          ],
        );
      },
    );
  }
}

class _ReportTab extends StatelessWidget {
  const _ReportTab({required this.research});

  final ResearchState research;

  @override
  Widget build(BuildContext context) {
    if (research.report.isEmpty) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuraIntelligenceIndicator(state: AuraState.thinking, size: 20),
            const SizedBox(width: AuraSpace.sm),
            Text('Writing report…', style: TextStyle(color: context.aura.text2)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AuraSpace.md),
      child: Text(research.report, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _SourcesTab extends StatelessWidget {
  const _SourcesTab({required this.research});

  final ResearchState research;

  @override
  Widget build(BuildContext context) {
    if (research.sources.isEmpty) {
      return Center(child: Text('No sources yet.', style: TextStyle(color: context.aura.text2)));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AuraSpace.md),
      itemCount: research.sources.length,
      separatorBuilder: (_, __) => const SizedBox(height: AuraSpace.sm),
      itemBuilder: (context, i) {
        final source = research.sources[i];
        return AuraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(source.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AuraSpace.xxs),
              Row(
                children: [
                  Expanded(child: Text(source.publisher, style: TextStyle(fontSize: 12, color: context.aura.text2))),
                  AuraStatusBadge(label: source.credibility.toUpperCase(), tone: AuraBadgeTone.violet),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
