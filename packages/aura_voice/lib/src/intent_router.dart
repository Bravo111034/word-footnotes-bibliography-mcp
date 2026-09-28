import 'intent.dart';

/// Maps a transcript to an [Intent] by keyword. A placeholder for the real
/// classifier (a small on-device model or an LLM call) — keeps the voice
/// overlay and downstream screens working end-to-end in the meantime.
class IntentRouter {
  const IntentRouter();

  static const _keywordMap = {
    IntentKind.research: ['research', 'look into', 'find out', 'investigate'],
    IntentKind.create: ['create', 'write', 'generate', 'draft'],
    IntentKind.task: ['schedule', 'remind', 'automate', 'set up a task'],
    IntentKind.navigate: ['open', 'go to', 'show me'],
  };

  Intent route(String transcript) {
    final lower = transcript.toLowerCase();

    for (final entry in _keywordMap.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          return Intent(kind: entry.key, confidence: 0.9, transcript: transcript);
        }
      }
    }

    if (transcript.trim().isEmpty) {
      return const Intent(kind: IntentKind.unknown, confidence: 0, transcript: '');
    }

    return Intent(kind: IntentKind.chat, confidence: 0.6, transcript: transcript);
  }
}
