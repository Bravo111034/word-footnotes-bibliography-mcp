import 'dart:async';

import 'package:aura_ai_gateway/aura_ai_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/brave_search_client.dart';
import '../services/searxng_search_client.dart';

class ResearchStep {
  const ResearchStep({required this.label, this.done = false});

  final String label;
  final bool done;

  ResearchStep copyWith({bool? done}) => ResearchStep(label: label, done: done ?? this.done);
}

class SourceItem {
  const SourceItem({required this.title, required this.publisher, required this.credibility, this.url});

  final String title;
  final String publisher;
  final String credibility;
  final String? url;
}

class ResearchState {
  const ResearchState({
    this.query = '',
    this.steps = const [],
    this.sources = const [],
    this.report = '',
    this.isRunning = false,
    this.error,
  });

  final String query;
  final List<ResearchStep> steps;
  final List<SourceItem> sources;
  final String report;
  final bool isRunning;
  final String? error;

  ResearchState copyWith({
    String? query,
    List<ResearchStep>? steps,
    List<SourceItem>? sources,
    String? report,
    bool? isRunning,
    String? error,
  }) {
    return ResearchState(
      query: query ?? this.query,
      steps: steps ?? this.steps,
      sources: sources ?? this.sources,
      report: report ?? this.report,
      isRunning: isRunning ?? this.isRunning,
      error: error ?? this.error,
    );
  }
}

const _planLabels = ['Planning', 'Searching the web', 'Reading sources', 'Cross-checking facts', 'Writing report'];

const _mockSources = [
  SourceItem(title: 'Global EV battery outlook 2026', publisher: 'IEA', credibility: 'Government'),
  SourceItem(title: 'Lithium supply constraints', publisher: 'Nature Energy', credibility: 'Academic'),
  SourceItem(title: 'Battery makers race for nickel', publisher: 'Reuters', credibility: 'News'),
];

/// Drives the Active Research screen: a plan, sources, and a report.
///
/// Sources come from a real web search when `SEARXNG_URL` (a self-hosted,
/// free, no-API-key SearXNG instance) or `BRAVE_API_KEY` is configured —
/// SearXNG is preferred when both are set. When `OPENAI_API_KEY` is also
/// configured, the report is written by a real OpenAI call grounded in
/// those sources' snippets. Without any of these, everything falls back to
/// a scripted mock so the screen still works end-to-end. This is a
/// placeholder for the real FastAPI + LangGraph agent (multi-step
/// planning, document reading, cross-checking) described in the roadmap —
/// a single search + single write call, not an agent loop.
class ResearchController extends StateNotifier<ResearchState> {
  ResearchController({
    SearxngSearchClient? searxngClient,
    BraveSearchClient? braveClient,
    AiGateway? aiGateway,
  })  : _searxngClient = searxngClient ?? SearxngSearchClient(),
        _braveClient = braveClient ?? BraveSearchClient(),
        _aiGateway = aiGateway ?? CompositeAiGateway(),
        super(const ResearchState());

  final SearxngSearchClient _searxngClient;
  final BraveSearchClient _braveClient;
  final AiGateway _aiGateway;

  Future<void> startResearch(String query) async {
    state = ResearchState(
      query: query,
      steps: _planLabels.map((l) => ResearchStep(label: l)).toList(),
      isRunning: true,
    );

    List<WebSearchResult> webResults = const [];

    for (var i = 0; i < state.steps.length; i++) {
      if (i == 1) {
        webResults = await _findSources(query);
      }

      await Future<void>.delayed(const Duration(milliseconds: 300));
      final steps = [...state.steps];
      steps[i] = steps[i].copyWith(done: true);
      state = state.copyWith(steps: steps);

      if (i == _planLabels.length - 1) {
        await _writeReport(query, webResults);
      }
    }

    state = state.copyWith(isRunning: false);
  }

  Future<List<WebSearchResult>> _findSources(String query) async {
    if (!AiConfig.hasSearxng && !AiConfig.hasBraveSearchKey) {
      state = state.copyWith(sources: _mockSources);
      return const [];
    }

    try {
      final results = AiConfig.hasSearxng
          ? await _searxngClient.search(query)
          : await _braveClient.search(query);
      state = state.copyWith(
        sources: results
            .map((r) => SourceItem(
                  title: r.title,
                  publisher: Uri.tryParse(r.url)?.host ?? r.url,
                  credibility: 'Web',
                  url: r.url,
                ))
            .toList(),
      );
      return results;
    } catch (e) {
      state = state.copyWith(sources: _mockSources, error: 'Web search failed: $e');
      return const [];
    }
  }

  Future<void> _writeReport(String query, List<WebSearchResult> webResults) async {
    if (webResults.isEmpty || !AiConfig.hasOpenAiKey) {
      await _streamMockReport(query);
      return;
    }

    final groundedPrompt = StringBuffer()
      ..writeln('Write a concise research report on: $query')
      ..writeln()
      ..writeln('Ground every claim in these sources and cite them by number inline like [1]:')
      ..writeln();
    for (var i = 0; i < webResults.length; i++) {
      groundedPrompt.writeln('[${i + 1}] ${webResults[i].title} — ${webResults[i].snippet} (${webResults[i].url})');
    }

    final history = [ChatMessage(role: ChatRole.user, content: groundedPrompt.toString())];
    final buffer = StringBuffer();
    try {
      await for (final chunk in _aiGateway.streamCompletion(history, provider: AiProvider.openai)) {
        buffer.write(chunk);
        state = state.copyWith(report: buffer.toString());
      }
    } catch (e) {
      state = state.copyWith(error: 'Report writing failed: $e');
      if (buffer.isEmpty) await _streamMockReport(query);
    }
  }

  Future<void> _streamMockReport(String query) async {
    final report = 'Research report: $query\n\n'
        'This is a placeholder report. A real run grounds every claim in '
        'real web sources — configure BRAVE_API_KEY and OPENAI_API_KEY to '
        'see it write a real, cited report instead.';

    final words = report.split(' ');
    var buffer = '';
    for (final word in words) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      buffer = buffer.isEmpty ? word : '$buffer $word';
      state = state.copyWith(report: buffer);
    }
  }
}

final researchControllerProvider = StateNotifierProvider<ResearchController, ResearchState>((ref) {
  return ResearchController();
});
