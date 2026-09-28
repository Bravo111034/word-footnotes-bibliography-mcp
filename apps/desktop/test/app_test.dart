import 'package:aura_desktop/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuraDesktopApp renders the Aura brand mark', (tester) async {
    await tester.pumpWidget(const AuraDesktopApp());
    await tester.pump();

    expect(find.text('Aura AI'), findsOneWidget);
  });
}
