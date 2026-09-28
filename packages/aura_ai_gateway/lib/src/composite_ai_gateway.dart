import 'ai_config.dart';
import 'ai_gateway.dart';
import 'ai_provider.dart';
import 'chat_message.dart';
import 'mock_ai_gateway.dart';
import 'openai_gateway.dart';

/// Routes each provider to a real backend when one is configured, and
/// falls back to [MockAiGateway] otherwise. This is the gateway the app
/// actually uses — add a case here as each provider's real client lands.
class CompositeAiGateway implements AiGateway {
  CompositeAiGateway({OpenAiGateway? openAi, MockAiGateway? mock})
      : _openAi = openAi ?? OpenAiGateway(),
        _mock = mock ?? const MockAiGateway();

  final OpenAiGateway _openAi;
  final MockAiGateway _mock;

  /// True once a provider that actually has a real backend implemented
  /// here is configured. Until Anthropic/Gemini/etc. get their own real
  /// clients, OpenAI is the only one — so every preset mode (Fast, Deep,
  /// Research, ...) routes there rather than silently serving mock text
  /// just because its label says a provider without a wired key.
  bool get _hasAnyRealBackend => AiConfig.hasOpenAiKey;

  @override
  bool isAvailable(AiProvider provider) {
    if (_hasAnyRealBackend) return true;
    return _mock.isAvailable(provider);
  }

  @override
  Stream<String> streamCompletion(List<ChatMessage> history, {required AiProvider provider}) {
    if (AiConfig.hasOpenAiKey) {
      return _openAi.streamCompletion(history, provider: provider);
    }
    return _mock.streamCompletion(history, provider: provider);
  }
}
