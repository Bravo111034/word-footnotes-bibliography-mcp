import 'package:aura_mobile/features/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatScreen sends the initial message and streams a mock reply', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ChatScreen(initialMessage: 'hello aura')),
      ),
    );

    await tester.pump();
    await tester.pump();
    expect(find.text('hello aura'), findsOneWidget);

    // _MessageTile's AuraIntelligenceIndicator animates forever, so
    // pumpAndSettle would never converge — advance a bounded, finite
    // amount of time instead (comfortably longer than the mock reply
    // takes to finish streaming).
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('placeholder response'), findsOneWidget);
  });
}
