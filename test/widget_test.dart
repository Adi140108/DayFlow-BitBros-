import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/main.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: DayflowApp()));
    expect(find.byType(DayflowApp), findsOneWidget);
  });
}
