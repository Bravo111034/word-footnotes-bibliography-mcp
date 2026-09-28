import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';

class _Stat {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;
}

const _stats = [
  _Stat(label: 'Posts published', value: '—'),
  _Stat(label: 'Total reach', value: '—'),
  _Stat(label: 'Avg. engagement', value: '—'),
  _Stat(label: 'Top platform', value: '—'),
];

/// Content Intelligence dashboard (spec §39). Values are placeholders —
/// per the spec this screen must only ever show real API metrics, never
/// invented numbers, so every stat renders "—" until a publishing platform
/// is connected.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(AuraSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AuraSpace.sm,
              crossAxisSpacing: AuraSpace.sm,
              childAspectRatio: 1.6,
              children: _stats.map((stat) {
                return AuraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(stat.value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: AuraSpace.xxs),
                      Text(stat.label, style: TextStyle(fontSize: 12, color: context.aura.text2)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AuraSpace.lg),
            Expanded(
              child: Center(
                child: Text(
                  'Connect a publishing integration to see performance over time,\nplatform breakdown, and top content.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.aura.text2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
