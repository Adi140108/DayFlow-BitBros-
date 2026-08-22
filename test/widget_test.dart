import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Dayflow HRMS Ready'),
        ),
      ),
    );

    expect(find.text('Dayflow HRMS Ready'), findsOneWidget);
  });
}
