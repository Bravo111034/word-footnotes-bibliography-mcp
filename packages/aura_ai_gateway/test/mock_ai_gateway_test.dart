import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MockAiGateway streams a non-empty reply mentioning the provider', () async {
    const gateway = MockAiGateway(wordDelay: Duration.zero);
    final history = [const ChatMessage(role: ChatRole.user, content: 'hello')];

    final chunks = await gateway.streamCompletion(history, provider: AiProvider.anthropic).toList();
    final full = chunks.join();

    expect(chunks, isNotEmpty);
    expect(full, contains('Claude'));
    expect(full, contains('hello'));
  });

  test('isAvailable reports true for every provider in the mock', () {
    const gateway = MockAiGateway();
    for (final provider in AiProvider.values) {
      expect(gateway.isAvailable(provider), isTrue);
    }
  });
}
