import 'package:aura_mobile/features/memory/memory_manager_screen.dart';
import 'package:aura_mobile/features/publishing/publishing_hub_screen.dart';
import 'package:aura_mobile/features/tasks/task_detail_screen.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AuraTheme.light, home: child);

void main() {
  testWidgets('Stopping a task requires confirming the permission dialog', (tester) async {
    await tester.pumpWidget(_wrap(const TaskDetailScreen(title: 'Publishing weekly newsletter')));
    await tester.pump();

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();

    expect(find.text('Stop this task?'), findsOneWidget);

    // Cancel leaves the screen in place.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stop task'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailScreen), findsNothing);
  });

  testWidgets('Forgetting a memory requires confirming, then removes it', (tester) async {
    await tester.pumpWidget(_wrap(const MemoryManagerScreen()));
    await tester.pump();

    // The Preferences section is below the fold in a lazily-built
    // ListView, so scroll it into view before asserting on it.
    await tester.dragUntilVisible(
      find.text('Default model: Balanced'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Default model: Balanced'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('Forget this?'), findsOneWidget);

    await tester.tap(find.text('Forget'));
    await tester.pumpAndSettle();

    expect(find.text('Default model: Balanced'), findsNothing);
  });

  testWidgets('Publishing an approved item requires confirming, then moves it to Published', (tester) async {
    await tester.pumpWidget(_wrap(const PublishingHubScreen()));
    await tester.pump();

    await tester.tap(find.text('Approved'));
    await tester.pumpAndSettle();

    expect(find.text('Battery report summary'), findsOneWidget);
    await tester.tap(find.text('Battery report summary'));
    await tester.pumpAndSettle();

    expect(find.text('Publish publicly?'), findsOneWidget);
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    expect(find.text('No Approved content'), findsOneWidget);

    await tester.tap(find.text('Published'));
    await tester.pumpAndSettle();
    expect(find.text('Battery report summary'), findsOneWidget);
  });
}
