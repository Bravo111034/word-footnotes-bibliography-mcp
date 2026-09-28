import 'package:aura_mobile/features/research/active_research_screen.dart';
import 'package:aura_mobile/features/research/research_home_screen.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Starting research navigates to the Active Research screen and streams a report', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AuraTheme.light, home: const ResearchHomeScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), 'EV battery supply chains');
    await tester.ensureVisible(find.text('Start Research'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Research'));
    await tester.pumpAndSettle();

    expect(find.byType(ActiveResearchScreen), findsOneWidget);

    await tester.tap(find.text('Report'));
    await tester.pump();

    // Plan steps complete every 300ms, then the report streams word by
    // word at 25ms/word — advance comfortably past both. No BRAVE_API_KEY/
    // OPENAI_API_KEY is set in tests, so this exercises the mock fallback.
    await tester.pump(const Duration(seconds: 4));

    expect(find.textContaining('Research report'), findsOneWidget);
  });
}
