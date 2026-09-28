import 'dart:convert';

import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:http/http.dart' as http;

import 'brave_search_client.dart';

/// A real web search backed by a self-hosted SearXNG instance. Requires
/// [AiConfig.searxngUrl] to be set at build time (a public URL, e.g. a
/// Railway/Fly deployment); callers should check [AiConfig.hasSearxng]
/// before using this. Free and API-key-less, unlike [BraveSearchClient].
class SearxngSearchClient {
  SearxngSearchClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<WebSearchResult>> search(String query, {int count = 5}) async {
    final base = AiConfig.searxngUrl;
    final uri = Uri.parse('$base/search').replace(queryParameters: {
      'q': query,
      'format': 'json',
      'categories': 'general',
    });

    final response = await _client.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception('SearXNG returned ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'] as List<dynamic>? ?? [];

    return results.take(count).map((r) {
      final result = r as Map<String, dynamic>;
      return WebSearchResult(
        title: result['title'] as String? ?? 'Untitled',
        url: result['url'] as String? ?? '',
        snippet: result['content'] as String? ?? '',
      );
    }).toList();
  }
}
