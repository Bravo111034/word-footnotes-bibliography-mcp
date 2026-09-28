import 'package:aura_voice/aura_voice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const router = IntentRouter();

  test('routes research phrases to IntentKind.research', () {
    final intent = router.route('Research the EV battery supply chain');
    expect(intent.kind, IntentKind.research);
    expect(intent.confidence, greaterThan(0.5));
  });

  test('routes unmatched phrases to chat with lower confidence', () {
    final intent = router.route('What is the weather like');
    expect(intent.kind, IntentKind.chat);
  });

  test('empty transcript routes to unknown with zero confidence', () {
    final intent = router.route('');
    expect(intent.kind, IntentKind.unknown);
    expect(intent.confidence, 0);
  });
}
