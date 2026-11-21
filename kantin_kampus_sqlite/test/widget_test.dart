import 'package:flutter_test/flutter_test.dart';
import 'package:kantin_kampus_sqlite/main.dart';

void main() {
  testWidgets('Kantin app displays the product list', (WidgetTester tester) async {
    await tester.pumpWidget(const KantinKampusApp());

    expect(find.text('Nasi Goreng'), findsOneWidget);
    expect(find.text('Es Teh Manis'), findsOneWidget);
  });
}
