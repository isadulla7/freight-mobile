import 'package:flutter_test/flutter_test.dart';
import 'package:freight_mobile/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const FreightApp());
    expect(find.text('Freight'), findsOneWidget);
  });
}
