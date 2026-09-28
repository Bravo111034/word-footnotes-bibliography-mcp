import 'package:aura_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AuraApp boots into Sign In when no session is persisted', (tester) async {
    // Splash and Sign In both host an AuraIntelligenceIndicator, whose
    // animation repeats forever — pumpAndSettle would never converge, so
    // advance a bounded, finite amount of time instead.
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome to Aura'), findsOneWidget);
  });
}
