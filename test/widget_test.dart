import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freight_mobile/core/di/service_locator.dart';
import 'package:freight_mobile/main.dart';

void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    sl.init();
  });

  testWidgets('App renders the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FreightApp());
    await tester.pumpAndSettle();

    expect(find.text('Freight'), findsOneWidget);
    expect(find.text('Yuk tashish xizmatiga xush kelibsiz'), findsOneWidget);
  });
}
