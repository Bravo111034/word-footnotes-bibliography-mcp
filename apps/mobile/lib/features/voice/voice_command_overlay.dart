import 'package:aura_ui/aura_ui.dart';
import 'package:aura_voice/aura_voice.dart';
import 'package:flutter/material.dart';

/// Full-screen voice overlay: animated Aura orb, live transcript, and a
/// confirm/cancel step once listening finishes (spec: voice command
/// overlay). Appears over any screen via [show].
class VoiceCommandOverlay extends StatefulWidget {
  const VoiceCommandOverlay({super.key, required this.pipeline, required this.router});

  final VoicePipeline pipeline;
  final IntentRouter router;

  static Future<VoiceIntent?> show(BuildContext context, {required VoicePipeline pipeline, required IntentRouter router}) {
    return showModalBottomSheet<VoiceIntent>(
      context: context,
      isScrollControlled: true,
      builder: (_) => VoiceCommandOverlay(pipeline: pipeline, router: router),
    );
  }

  @override
  State<VoiceCommandOverlay> createState() => _VoiceCommandOverlayState();
}

class _VoiceCommandOverlayState extends State<VoiceCommandOverlay> {
  VoiceEvent _event = const VoiceEvent(state: VoiceState.idle);
  VoiceIntent? _routedIntent;

  @override
  void initState() {
    super.initState();
    widget.pipeline.startListening().listen((event) {
      if (!mounted) return;
      setState(() => _event = event);
      if (event.state == VoiceState.done) {
        setState(() => _routedIntent = widget.router.route(event.transcript));
      }
    });
  }

  @override
  void dispose() {
    widget.pipeline.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicatorState = switch (_event.state) {
      VoiceState.listening => AuraState.thinking,
      VoiceState.transcribing => AuraState.searching,
      VoiceState.done => AuraState.complete,
      VoiceState.error => AuraState.error,
      VoiceState.idle => AuraState.idle,
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AuraSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuraIntelligenceIndicator(state: indicatorState, size: 64),
            const SizedBox(height: AuraSpace.lg),
            Text(
              _event.transcript.isEmpty ? 'Listening…' : _event.transcript,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AuraSpace.lg),
            if (_routedIntent != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AuraSpace.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_routedIntent),
                      child: Text('Go: ${_routedIntent!.kind.name}'),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}
