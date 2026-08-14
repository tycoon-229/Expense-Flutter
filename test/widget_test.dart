import 'package:flutter_test/flutter_test.dart';
import 'package:expense/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
