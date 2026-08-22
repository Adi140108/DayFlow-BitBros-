import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/theme/app_colors.dart';
import 'package:dayflow/core/theme/app_theme.dart';
import 'package:dayflow/core/components/app_button.dart';
import 'package:dayflow/core/components/app_badge.dart';

void main() {
  group('Dayflow Design Tokens Tests', () {
    test('AppColors primary token is defined correctly', () {
      expect(AppColors.primary, equals(const Color(0xFF2563EB)));
    });

    test('AppTheme Light and Dark themes initialize with Material 3', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;
      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
      expect(light.brightness, equals(Brightness.light));
      expect(dark.brightness, equals(Brightness.dark));
    });
  });

  group('Dayflow Component Widget Tests', () {
    testWidgets('AppButton renders label correctly and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Test Button',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('AppStatusBadge renders success status', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppStatusBadge.success(label: 'Active'),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });
  });
}
