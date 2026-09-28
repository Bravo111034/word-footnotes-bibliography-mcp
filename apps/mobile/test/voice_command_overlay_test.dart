import 'package:aura_mobile/features/voice/voice_command_overlay.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:aura_voice/aura_voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('VoiceCommandOverlay routes the scripted transcript and returns the intent', (tester) async {
    Intent? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AuraTheme.light,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await VoiceCommandOverlay.show(
                context,
                pipeline: MockVoicePipeline(scriptedPhrase: 'Research the EV battery supply chain'),
                router: const IntentRouter(),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();

    // Scripted phrase streams word by word every 180ms (7 words).
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('Go:'), findsOneWidget);
    await tester.tap(find.textContaining('Go:'));
    await tester.pump(const Duration(seconds: 1));

    expect(result?.kind, IntentKind.research);
  });
}
