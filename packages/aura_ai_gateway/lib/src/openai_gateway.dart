import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_config.dart';
import 'ai_gateway.dart';
import 'ai_provider.dart';
import 'chat_message.dart';

/// A real [AiGateway] backed by OpenAI's Chat Completions API. Streams
/// tokens as they arrive via server-sent events. Requires
/// [AiConfig.openAiApiKey] to be set at build time.
///
/// Only [AiProvider.openai] is backed by a real call; every other provider
/// still falls back to a canned reply, since only an OpenAI key was
/// configured. Add a sibling class per provider (Anthropic, Gemini) the
/// same way once those keys are available.
class OpenAiGateway implements AiGateway {
  OpenAiGateway({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  @override
  bool isAvailable(AiProvider provider) {
    if (provider == AiProvider.openai) return AiConfig.hasOpenAiKey;
    return false;
  }

  @override
  Stream<String> streamCompletion(List<ChatMessage> history, {required AiProvider provider}) async* {
    if (provider != AiProvider.openai || !AiConfig.hasOpenAiKey) {
      yield "This provider isn't configured with a real API key yet — "
          'only OpenAI is wired up. Falling back to a placeholder reply.';
      return;
    }

    final request = http.Request('POST', Uri.parse(_endpoint))
      ..headers['Authorization'] = 'Bearer ${AiConfig.openAiApiKey}'
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': 'gpt-4o-mini',
        'stream': true,
        'messages': [
          for (final message in history)
            {
              'role': message.role == ChatRole.user ? 'user' : 'assistant',
              'content': message.content,
            },
        ],
      });

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } catch (e) {
      yield 'Could not reach OpenAI: $e';
      return;
    }

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      yield 'OpenAI returned an error (${response.statusCode}): $body';
      return;
    }

    final lines = response.stream.transform(utf8.decoder).transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final payload = line.substring(6).trim();
      if (payload == '[DONE]') break;

      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final choices = decoded['choices'] as List<dynamic>?;
        final delta = choices?.isNotEmpty == true ? choices!.first['delta'] as Map<String, dynamic>? : null;
        final content = delta?['content'] as String?;
        if (content != null && content.isNotEmpty) yield content;
      } catch (_) {
        // Skip malformed/partial SSE chunks rather than failing the stream.
      }
    }
  }
}
