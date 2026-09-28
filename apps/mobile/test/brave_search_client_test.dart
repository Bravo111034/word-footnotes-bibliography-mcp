import 'dart:convert';

import 'package:aura_mobile/core/services/brave_search_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('BraveSearchClient parses web results and strips HTML from snippets', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'api.search.brave.com');
      expect(request.headers['X-Subscription-Token'], isNotNull);

      return http.Response(
        jsonEncode({
          'web': {
            'results': [
              {
                'title': 'EV battery outlook',
                'url': 'https://iea.org/ev-battery-outlook',
                'description': 'A <strong>global</strong> look at battery demand.',
              },
            ],
          },
        }),
        200,
      );
    });

    final results = await BraveSearchClient(client: client).search('EV batteries');

    expect(results, hasLength(1));
    expect(results.first.title, 'EV battery outlook');
    expect(results.first.url, 'https://iea.org/ev-battery-outlook');
    expect(results.first.snippet, 'A global look at battery demand.');
  });

  test('BraveSearchClient throws on a non-200 response', () async {
    final client = MockClient((request) async => http.Response('rate limited', 429));

    expect(() => BraveSearchClient(client: client).search('EV batteries'), throwsException);
  });
}
