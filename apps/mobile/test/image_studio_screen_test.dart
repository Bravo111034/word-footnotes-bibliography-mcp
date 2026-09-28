import 'package:aura_mobile/features/image_studio/image_studio_screen.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ImageStudioScreen generates variations for a prompt', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AuraTheme.light, home: const ImageStudioScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No image yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a cozy reading nook');
    await tester.tap(find.text('Generate'));
    await tester.pump();

    expect(find.text('Generating...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Variations'), findsOneWidget);
    expect(find.text('No image yet'), findsNothing);
  });
}
