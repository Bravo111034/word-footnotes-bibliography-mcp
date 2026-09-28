import 'package:aura_mobile/main.dart';
import 'package:aura_ui/aura_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuraApp boots into the widget catalog', (tester) async {
    await tester.pumpWidget(const AuraApp());
    await tester.pump();

    expect(find.text('Aura Widget Catalog'), findsOneWidget);
    expect(find.byType(AuraIntelligenceIndicator), findsWidgets);
  });
}
