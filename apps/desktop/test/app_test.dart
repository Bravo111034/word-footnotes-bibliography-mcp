import 'package:aura_desktop/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuraDesktopApp renders the 3-region shell', (tester) async {
    await tester.pumpWidget(const AuraDesktopApp());
    await tester.pump();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Home workspace'), findsOneWidget);
  });
}
