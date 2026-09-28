import 'package:aura_voice/aura_voice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MockVoicePipeline streams listening, transcribing, then done', () async {
    final pipeline = MockVoicePipeline(scriptedPhrase: 'hello world');
    final events = await pipeline.startListening().toList();

    expect(events.first.state, VoiceState.listening);
    expect(events.last.state, VoiceState.done);
    expect(events.last.transcript, 'hello world');
  });
}
