import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuraIntelligenceIndicator renders for every state', (tester) async {
    for (final state in AuraState.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AuraTheme.light,
          home: Scaffold(body: AuraIntelligenceIndicator(state: state)),
        ),
      );
      expect(find.byType(AuraIntelligenceIndicator), findsOneWidget);
    }
  });

  testWidgets('AuraCard responds to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AuraTheme.light,
        home: Scaffold(
          body: AuraCard(
            onTap: () => tapped = true,
            child: const Text('tap me'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('tap me'));
    expect(tapped, isTrue);
  });
}
