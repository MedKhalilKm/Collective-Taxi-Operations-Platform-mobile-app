import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('App initializes splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TaxiCollectifApp());
    expect(find.text('Taxi Collectif'), findsOneWidget);
  });
}
