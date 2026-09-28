import 'package:aura_mobile/features/publishing/publishing_hub_screen.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Running the Drafts workflow through Approval and Publish moves it to Published', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AuraTheme.light, home: const PublishingHubScreen()));
    await tester.pump();

    expect(find.text('Q3 recap carousel'), findsOneWidget);
    await tester.tap(find.text('Q3 recap carousel'));
    await tester.pumpAndSettle();

    expect(find.text('Content'), findsWidgets);

    // Step through Content, Destinations, Adapt, Preview (4 "Next" taps),
    // then confirm the Approval permission dialog, then Publish, then Done.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(find.text('Approve for publishing?'), findsOneWidget);
    await tester.tap(find.text('Approve').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('No Drafts content'), findsOneWidget);

    await tester.tap(find.text('Published'));
    await tester.pumpAndSettle();
    expect(find.text('Q3 recap carousel'), findsOneWidget);
  });
}
