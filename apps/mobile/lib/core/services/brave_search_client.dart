import 'dart:convert';

import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:http/http.dart' as http;

class WebSearchResult {
  const WebSearchResult({required this.title, required this.url, required this.snippet});

  final String title;
  final String url;
  final String snippet;
}

/// A real web search backed by the Brave Search API. Requires
/// [AiConfig.braveSearchApiKey] to be set at build time; callers should
/// check [AiConfig.hasBraveSearchKey] before using this and fall back to
/// mock sources otherwise.
class BraveSearchClient {
  BraveSearchClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://api.search.brave.com/res/v1/web/search';

  Future<List<WebSearchResult>> search(String query, {int count = 5}) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {'q': query, 'count': '$count'});

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'X-Subscription-Token': AiConfig.braveSearchApiKey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Brave Search returned ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (decoded['web'] as Map<String, dynamic>?)?['results'] as List<dynamic>? ?? [];

    return results.map((r) {
      final result = r as Map<String, dynamic>;
      return WebSearchResult(
        title: result['title'] as String? ?? 'Untitled',
        url: result['url'] as String? ?? '',
        snippet: (result['description'] as String? ?? '').replaceAll(RegExp(r'<[^>]*>'), ''),
      );
    }).toList();
  }
}
