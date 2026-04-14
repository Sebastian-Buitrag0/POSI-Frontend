import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:posi_frontend/main.dart';

void main() {
  testWidgets('POSI app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: POSIApp()));
    expect(find.text('POSI'), findsOneWidget);
  });
}
