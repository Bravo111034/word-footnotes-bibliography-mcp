import 'dart:convert';

import 'package:aura_mobile/core/services/searxng_search_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('SearxngSearchClient parses results from the JSON API', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('/search'));
      expect(request.url.queryParameters['format'], 'json');

      return http.Response(
        jsonEncode({
          'results': [
            {
              'title': 'EV battery outlook',
              'url': 'https://iea.org/ev-battery-outlook',
              'content': 'A global look at battery demand.',
            },
          ],
        }),
        200,
      );
    });

    final results = await SearxngSearchClient(client: client).search('EV batteries');

    expect(results, hasLength(1));
    expect(results.first.title, 'EV battery outlook');
    expect(results.first.url, 'https://iea.org/ev-battery-outlook');
    expect(results.first.snippet, 'A global look at battery demand.');
  });

  test('SearxngSearchClient throws on a non-200 response', () async {
    final client = MockClient((request) async => http.Response('bad gateway', 502));

    expect(() => SearxngSearchClient(client: client).search('EV batteries'), throwsException);
  });
}
