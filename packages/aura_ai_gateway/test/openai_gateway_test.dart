import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OpenAiGateway falls back to a placeholder without a configured key', () async {
    final gateway = OpenAiGateway();
    expect(gateway.isAvailable(AiProvider.openai), isFalse);

    final chunks = await gateway
        .streamCompletion([const ChatMessage(role: ChatRole.user, content: 'hi')], provider: AiProvider.openai)
        .toList();

    expect(chunks.join(), contains("isn't configured"));
  });

  test('OpenAiGateway reports every non-OpenAI provider as unavailable', () {
    final gateway = OpenAiGateway();
    for (final provider in AiProvider.values.where((p) => p != AiProvider.openai)) {
      expect(gateway.isAvailable(provider), isFalse);
    }
  });
}
