import 'dart:async';

import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which [AiProvider] backs each [AiMode] preset, until per-mode routing
/// (cost/latency-aware selection) replaces this fixed map.
const _modeProviders = {
  AiMode.auto: AiProvider.anthropic,
  AiMode.fast: AiProvider.anthropic,
  AiMode.balanced: AiProvider.openai,
  AiMode.deep: AiProvider.anthropic,
  AiMode.research: AiProvider.gemini,
  AiMode.creative: AiProvider.openai,
};

final aiGatewayProvider = Provider<AiGateway>((ref) => const MockAiGateway());

final aiModeProvider = StateProvider<AiMode>((ref) => AiMode.auto);

/// The provider actually used when [AiMode.custom] is selected.
final customProviderProvider = StateProvider<AiProvider>((ref) => AiProvider.anthropic);

/// Resolves the active [AiMode] (and, for custom, the pinned provider) to
/// the [AiProvider] that should serve the next message.
final activeProviderProvider = Provider<AiProvider>((ref) {
  final mode = ref.watch(aiModeProvider);
  if (mode == AiMode.custom) return ref.watch(customProviderProvider);
  return _modeProviders[mode]!;
});

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController(this._ref) : super(const []);

  final Ref _ref;
  StreamSubscription<String>? _subscription;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = [...state, ChatMessage(role: ChatRole.user, content: trimmed)];
    state = [...state, const ChatMessage(role: ChatRole.assistant, content: '', isStreaming: true)];

    final gateway = _ref.read(aiGatewayProvider);
    final provider = _ref.read(activeProviderProvider);

    await _subscription?.cancel();
    final buffer = StringBuffer();
    _subscription = gateway.streamCompletion(state, provider: provider).listen(
      (chunk) {
        buffer.write(chunk);
        _replaceLastAssistantMessage(buffer.toString(), isStreaming: true);
      },
      onDone: () => _replaceLastAssistantMessage(buffer.toString(), isStreaming: false),
    );
  }

  void _replaceLastAssistantMessage(String content, {required bool isStreaming}) {
    final updated = [...state];
    updated[updated.length - 1] = updated.last.copyWith(content: content, isStreaming: isStreaming);
    state = updated;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  return ChatController(ref);
});
