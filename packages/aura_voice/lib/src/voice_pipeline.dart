enum VoiceState { idle, listening, transcribing, done, error }

/// One snapshot of a voice session: partial or final transcript, plus state.
class VoiceEvent {
  const VoiceEvent({required this.state, this.transcript = ''});

  final VoiceState state;
  final String transcript;
}

/// Mic capture through to a transcript. Real backends (Whisper.cpp locally,
/// Deepgram over WebSocket for online) implement this; the UI only depends
/// on the stream contract.
abstract class VoicePipeline {
  Stream<VoiceEvent> startListening();
  Future<void> stopListening();

  /// Whether on-device (offline) transcription is available on this
  /// platform right now.
  bool get supportsOffline;
}
