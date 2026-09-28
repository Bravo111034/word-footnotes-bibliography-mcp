import 'package:aura_mobile/features/library/file_preview_screen.dart';
import 'package:aura_mobile/features/library/library_screen.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AuraTheme.light, home: child);

void main() {
  testWidgets('LibraryScreen filters by folder and opens a file preview', (tester) async {
    await tester.pumpWidget(_wrap(const LibraryScreen()));
    await tester.pump();

    expect(find.text('EV battery report.pdf'), findsOneWidget);

    await tester.tap(find.text('Images'));
    await tester.pump();
    expect(find.text('EV battery report.pdf'), findsNothing);
    expect(find.text('Brand moodboard.png'), findsOneWidget);

    await tester.tap(find.text('Brand moodboard.png'));
    await tester.pumpAndSettle();

    expect(find.byType(FilePreviewScreen), findsOneWidget);
    expect(find.text('Ask Aura about this file'), findsOneWidget);
  });

  testWidgets('LibraryScreen toggles between grid and list view', (tester) async {
    await tester.pumpWidget(_wrap(const LibraryScreen()));
    await tester.pump();

    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.byIcon(Icons.view_list_outlined));
    await tester.pump();

    expect(find.byType(GridView), findsNothing);
    expect(find.text('EV battery report.pdf'), findsOneWidget);
  });
}
