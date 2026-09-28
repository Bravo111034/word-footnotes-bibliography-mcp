import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/chat_state.dart';
import 'model_selector.dart';

/// The chat workspace (spec §11-13): a conversation column with user cards
/// and bare Aura responses (no bubbles), a thinking indicator while the
/// reply streams, and a model selector in the app bar.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.initialMessage});

  final String? initialMessage;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMessage;
    if (initial != null && initial.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(initial));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final value = text ?? _controller.text;
    if (value.trim().isEmpty) return;
    ref.read(chatControllerProvider.notifier).sendMessage(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: const [Padding(padding: EdgeInsets.only(right: AuraSpace.md), child: ModelSelector())],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(child: Text('Ask Aura anything to get started.', style: TextStyle(color: context.aura.text2)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AuraSpace.md),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _MessageTile(message: messages[i]),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AuraSpace.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask Aura anything...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AuraSpace.xs),
                  IconButton.filled(onPressed: () => _send(), icon: const Icon(Icons.arrow_upward)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: AuraSpace.md),
          padding: const EdgeInsets.symmetric(horizontal: AuraSpace.md, vertical: AuraSpace.sm),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: AuraColors.violet.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AuraRadius.lg),
          ),
          child: Text(message.content),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpace.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuraIntelligenceIndicator(
            state: message.isStreaming ? AuraState.thinking : AuraState.complete,
            size: 22,
          ),
          const SizedBox(width: AuraSpace.sm),
          Expanded(
            child: message.content.isEmpty
                ? Text('Thinking…', style: TextStyle(color: context.aura.text2, fontStyle: FontStyle.italic))
                : Text(message.content),
          ),
        ],
      ),
    );
  }
}
