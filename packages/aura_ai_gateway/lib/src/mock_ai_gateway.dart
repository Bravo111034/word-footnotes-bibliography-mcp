import 'ai_gateway.dart';
import 'ai_provider.dart';
import 'chat_message.dart';

/// A stand-in [AiGateway] that streams back a canned, provider-flavored
/// reply word by word. Lets the chat UI, model selector, and persistence be
/// built and tested end-to-end before real provider SDKs (Anthropic,
/// OpenAI, Gemini) and local inference (llama.cpp/Ollama) are wired in.
class MockAiGateway implements AiGateway {
  const MockAiGateway({this.wordDelay = const Duration(milliseconds: 40)});

  final Duration wordDelay;

  @override
  bool isAvailable(AiProvider provider) => true;

  @override
  Stream<String> streamCompletion(List<ChatMessage> history, {required AiProvider provider}) async* {
    final lastUserMessage = history.lastWhere(
      (m) => m.role == ChatRole.user,
      orElse: () => const ChatMessage(role: ChatRole.user, content: ''),
    );

    final reply = 'Thanks for asking${lastUserMessage.content.isEmpty ? '' : ' about "${lastUserMessage.content}"'}. '
        "I'm running as ${provider.displayName} right now — this is a placeholder response until real "
        'provider streaming is wired in.';

    final words = reply.split(' ');
    for (var i = 0; i < words.length; i++) {
      await Future<void>.delayed(wordDelay);
      yield i == 0 ? words[i] : ' ${words[i]}';
    }
  }
}
