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

  testWidgets('AuraCommandBar opens the palette on tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AuraTheme.light,
        home: Scaffold(body: AuraCommandBar(onTap: () => tapped = true)),
      ),
    );

    await tester.tap(find.byType(AuraCommandBar));
    expect(tapped, isTrue);
  });

  testWidgets('AuraTopBar renders title and responds to search tap', (tester) async {
    var searched = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AuraTheme.light,
        home: Scaffold(appBar: AuraTopBar(title: 'Home', onSearchTap: () => searched = true)),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.search));
    expect(searched, isTrue);
  });

  testWidgets('AuraSidebar renders items and responds to selection', (tester) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: AuraTheme.light,
        home: Scaffold(
          body: AuraSidebar(
            items: const [
              AuraSidebarItem(icon: Icons.home_outlined, label: 'Home'),
              AuraSidebarItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
            ],
            selectedIndex: 0,
            onSelect: (i) => selected = i,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Chat'));
    expect(selected, 1);
  });
}
