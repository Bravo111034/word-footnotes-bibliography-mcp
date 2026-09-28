enum IntentKind { research, chat, create, task, navigate, unknown }

/// A routed voice command: which [IntentKind] it maps to, the confidence
/// score, and the raw transcript for the target screen to act on.
class Intent {
  const Intent({required this.kind, required this.confidence, required this.transcript});

  final IntentKind kind;
  final double confidence;
  final String transcript;
}
