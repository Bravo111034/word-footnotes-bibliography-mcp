import 'package:aura_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AuraApp boots into Sign In when no session is persisted', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Aura'), findsOneWidget);
  });
}
