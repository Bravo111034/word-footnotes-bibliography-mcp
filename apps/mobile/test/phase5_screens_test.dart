import 'package:aura_mobile/features/analytics/analytics_screen.dart';
import 'package:aura_mobile/features/integrations/integrations_screen.dart';
import 'package:aura_mobile/features/more/more_screen.dart';
import 'package:aura_mobile/features/publishing/publishing_hub_screen.dart';
import 'package:aura_mobile/features/settings/settings_detail_screen.dart';
import 'package:aura_mobile/features/settings/settings_screen.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AuraTheme.light, home: child);

void main() {
  testWidgets('PublishingHubScreen renders its tabs', (tester) async {
    await tester.pumpWidget(_wrap(const PublishingHubScreen()));
    await tester.pump();

    expect(find.text('Drafts'), findsOneWidget);
    expect(find.text('Q3 recap carousel'), findsOneWidget);
  });

  testWidgets('AnalyticsScreen shows placeholder stats, never invented numbers', (tester) async {
    await tester.pumpWidget(_wrap(const AnalyticsScreen()));
    await tester.pump();

    expect(find.text('Posts published'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
  });

  testWidgets('IntegrationsScreen lists categories with status pills', (tester) async {
    await tester.pumpWidget(_wrap(const IntegrationsScreen()));
    await tester.pump();

    expect(find.text('Anthropic'), findsOneWidget);
    expect(find.text('CONNECTED'), findsWidgets);
  });

  testWidgets('SettingsScreen opens Integrations for Connected Apps, else a placeholder', (tester) async {
    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.tap(find.text('Connected Apps'));
    await tester.pumpAndSettle();
    expect(find.byType(IntegrationsScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsDetailScreen), findsOneWidget);
  });

  testWidgets('MoreScreen lists every secondary destination', (tester) async {
    await tester.pumpWidget(_wrap(const MoreScreen()));
    await tester.pump();

    expect(find.text('Publishing'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
