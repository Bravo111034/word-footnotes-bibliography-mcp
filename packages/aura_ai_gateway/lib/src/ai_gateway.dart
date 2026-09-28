import 'ai_provider.dart';
import 'chat_message.dart';

/// The unified interface every provider backend implements: given a
/// conversation so far, stream back the next assistant reply token by
/// token (or chunk by chunk).
abstract class AiGateway {
  Stream<String> streamCompletion(List<ChatMessage> history, {required AiProvider provider});

  /// Whether [provider] currently looks reachable (used to render the
  /// status pills in the model selector). Real providers check auth/network;
  /// [AiProvider.ollamaLocal] checks for a local runtime instead.
  bool isAvailable(AiProvider provider);
}
