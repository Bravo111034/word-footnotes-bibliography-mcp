/// API keys are read at build time via `--dart-define`, never committed to
/// source or hardcoded. Run with e.g.
/// `flutter run --dart-define=OPENAI_API_KEY=sk-...`, or bake them into a CI
/// build from repository secrets. An empty key means "no real credential
/// configured" — callers fall back to a mock in that case.
///
/// Security note: a key passed this way still ends up embedded in the
/// compiled app binary and can be extracted by anyone who has the APK/IPA —
/// `--dart-define` only keeps it out of git, not out of the shipped app.
/// A production build should proxy provider calls through a backend that
/// holds the real key server-side instead.
class AiConfig {
  AiConfig._();

  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const braveSearchApiKey = String.fromEnvironment('BRAVE_API_KEY');

  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
  static bool get hasBraveSearchKey => braveSearchApiKey.isNotEmpty;
}
