import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('DOBScreen', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const TestWrapper(
          child: DOBScreen(),
        ),
      );
      await tester.pump();
    }

    Future<void> selectDate(WidgetTester tester, DateTime date) async {
      // Find and tap the TextField directly
      await tester.tap(
        find.byType(TextField),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      // Wait for date picker to appear and verify
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Select today's date (or any valid date)
      await tester.tap(
        find.text('OK'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      
      expect(find.text('When\'s your\nbirthday?'), findsOneWidget);
      expect(find.text('We\'ll use this to find age-specific scholarships.'), findsOneWidget);
      expect(find.text('MM/DD/YYYY'), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('shows date picker with correct theme when tapped', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final dateInput = find.ancestor(
        of: find.byType(TextField),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(dateInput.first);
      await tester.pumpAndSettle();

      final datePicker = find.byType(DatePickerDialog);
      expect(datePicker, findsOneWidget);

      // Verify theme colors
      final theme = Theme.of(tester.element(datePicker));
      expect(theme.colorScheme.primary, Colors.white);
      expect(theme.colorScheme.onPrimary, Colors.black);
      expect(theme.colorScheme.surface, const Color(0xFF7B4DFF));
      expect(theme.colorScheme.onSurface, Colors.white);
    });

    testWidgets('date picker has correct date range', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final dateInput = find.ancestor(
        of: find.byType(TextField),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(dateInput.first);
      await tester.pumpAndSettle();

      final datePicker = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
      
      expect(
        datePicker.initialDate?.year,
        DateTime.now().subtract(const Duration(days: 365 * 18)).year,
      );
      expect(datePicker.firstDate?.year, 1900);
      expect(datePicker.lastDate?.year, DateTime.now().year);
    });

    testWidgets('navigates to CitizenshipScreen on next', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: DOBScreen(),
        ),
      );

      // Select a date
      await selectDate(tester, DateTime(2000, 1, 1));
      await tester.pumpAndSettle();

      // Navigate to next screen
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(CitizenshipScreen), findsOneWidget);
    });

    testWidgets('next button enables when date is selected', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially disabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Select a date
      await selectDate(tester, DateTime(2000, 1, 1));

      // Button should be enabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('back button navigates to PhoneNumberScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const DOBScreen(),
          routes: {
            '/phone': (context) => const PhoneNumberScreen(),
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneNumberScreen), findsOneWidget);
    });
  });
} 