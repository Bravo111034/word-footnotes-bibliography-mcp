enum ChatRole { user, assistant }

/// One message in a conversation. Immutable; a streaming assistant reply is
/// modeled by replacing the message with an updated copy as tokens arrive.
class ChatMessage {
  const ChatMessage({required this.role, required this.content, this.isStreaming = false});

  final ChatRole role;
  final String content;
  final bool isStreaming;

  ChatMessage copyWith({String? content, bool? isStreaming}) {
    return ChatMessage(
      role: role,
      content: content ?? this.content,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
