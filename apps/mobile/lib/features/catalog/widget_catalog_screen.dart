import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

/// A living preview of every Aura primitive, used for rapid UI QA while the
/// design system grows (P0 task 08). Add new sections here as widgets land.
class WidgetCatalogScreen extends StatelessWidget {
  const WidgetCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AuraGradientText('Aura Widget Catalog')),
      body: ListView(
        padding: const EdgeInsets.all(AuraSpace.lg),
        children: [
          _Section(
            title: 'Intelligence Indicator',
            child: Wrap(
              spacing: AuraSpace.lg,
              runSpacing: AuraSpace.lg,
              children: AuraState.values
                  .map((state) => _LabeledIndicator(state: state))
                  .toList(),
            ),
          ),
          const SizedBox(height: AuraSpace.xl),
          _Section(
            title: 'Status Badges',
            child: Wrap(
              spacing: AuraSpace.sm,
              children: const [
                AuraStatusBadge(label: 'NEUTRAL'),
                AuraStatusBadge(label: 'ACTIVE', tone: AuraBadgeTone.violet),
                AuraStatusBadge(label: 'DONE', tone: AuraBadgeTone.success),
                AuraStatusBadge(label: 'WAITING', tone: AuraBadgeTone.warning),
                AuraStatusBadge(label: 'FAILED', tone: AuraBadgeTone.error),
              ],
            ),
          ),
          const SizedBox(height: AuraSpace.xl),
          _Section(
            title: 'Card & Border',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuraCard(
                  onTap: () {},
                  child: const Text('AuraCard — tappable surface with hairline border'),
                ),
                const SizedBox(height: AuraSpace.sm),
                AuraBorder(
                  child: Padding(
                    padding: const EdgeInsets.all(AuraSpace.md),
                    child: const Text('AuraBorder — border only, no surface fill'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AuraSpace.sm),
        child,
      ],
    );
  }
}

class _LabeledIndicator extends StatelessWidget {
  const _LabeledIndicator({required this.state});

  final AuraState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuraIntelligenceIndicator(state: state, size: 40),
        const SizedBox(height: AuraSpace.xxs),
        Text(state.name, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
