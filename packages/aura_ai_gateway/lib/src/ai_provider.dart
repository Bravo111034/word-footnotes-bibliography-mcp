/// The AI providers Aura can route a request to. Real wiring (API keys,
/// SDKs, local inference) lands with the backend integration phase; the
/// gateway interface is stable now so chat UI can be built against it.
enum AiProvider { anthropic, openai, gemini, ollamaLocal }

extension AiProviderLabel on AiProvider {
  String get displayName => switch (this) {
        AiProvider.anthropic => 'Claude',
        AiProvider.openai => 'GPT',
        AiProvider.gemini => 'Gemini',
        AiProvider.ollamaLocal => 'Local (offline)',
      };

  bool get isOffline => this == AiProvider.ollamaLocal;
}

/// The model-selector presets from the roadmap (spec §15): each maps to a
/// provider + a request for speed vs. depth. "Custom" lets the user pin a
/// specific [AiProvider] directly.
enum AiMode { auto, fast, balanced, deep, research, creative, custom }

extension AiModeLabel on AiMode {
  String get displayName => switch (this) {
        AiMode.auto => 'Auto',
        AiMode.fast => 'Fast',
        AiMode.balanced => 'Balanced',
        AiMode.deep => 'Deep',
        AiMode.research => 'Research',
        AiMode.creative => 'Creative',
        AiMode.custom => 'Custom',
      };
}
