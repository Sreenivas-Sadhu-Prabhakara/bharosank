import 'package:flutter_test/flutter_test.dart';

import 'package:bharosank_app/main.dart';

void main() {
  test('evaluate applies the owner rule and floors at zero', () {
    expect(evaluate(8000, 50, 2, 500).limit, closeTo(3000, 1e-9));
    expect(evaluate(1000, 50, 5, 500).limit, 0);
  });

  testWidgets('renders the worksheet', (tester) async {
    await tester.pumpWidget(const BharosankApp());
    expect(find.text('Recommended credit limit'), findsOneWidget);
  });
}
