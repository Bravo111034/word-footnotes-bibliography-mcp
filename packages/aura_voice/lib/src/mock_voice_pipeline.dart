import 'dart:async';

import 'voice_pipeline.dart';

/// A stand-in [VoicePipeline] that "hears" a fixed phrase, word by word,
/// so the mic overlay and intent routing can be built before Whisper.cpp
/// (offline) and Deepgram (online) are wired in.
class MockVoicePipeline implements VoicePipeline {
  MockVoicePipeline({this.scriptedPhrase = 'Research the EV battery supply chain'});

  final String scriptedPhrase;
  StreamController<VoiceEvent>? _controller;

  @override
  bool get supportsOffline => true;

  @override
  Stream<VoiceEvent> startListening() {
    final controller = StreamController<VoiceEvent>();
    _controller = controller;

    unawaited(() async {
      controller.add(const VoiceEvent(state: VoiceState.listening));
      final words = scriptedPhrase.split(' ');
      var partial = '';
      for (final word in words) {
        if (controller.isClosed) return;
        await Future<void>.delayed(const Duration(milliseconds: 180));
        partial = partial.isEmpty ? word : '$partial $word';
        controller.add(VoiceEvent(state: VoiceState.transcribing, transcript: partial));
      }
      if (!controller.isClosed) {
        controller.add(VoiceEvent(state: VoiceState.done, transcript: partial));
        await controller.close();
      }
    }());

    return controller.stream;
  }

  @override
  Future<void> stopListening() async {
    await _controller?.close();
  }
}
