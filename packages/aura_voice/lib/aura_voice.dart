/// Voice pipeline + intent routing: mic capture through transcript to a
/// routed [Intent], with a provider-agnostic [VoicePipeline] interface.
library aura_voice;

export 'src/voice_pipeline.dart';
export 'src/mock_voice_pipeline.dart';
export 'src/intent.dart';
export 'src/intent_router.dart';
