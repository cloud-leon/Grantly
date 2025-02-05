import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import '../../helpers/test_wrapper.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';

void main() {
  group('LastNameScreen', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const TestWrapper(
          child: LastNameScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      
      expect(find.text('What\'s your last name?'), findsOneWidget);
      expect(find.text('We\'ll use this on your applications.'), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('shows text field with correct hint', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter your last name'), findsOneWidget);
    });

    testWidgets('validates input correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Test empty input
      await tester.enterText(find.byType(TextField), '');
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Test invalid input
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump(const Duration(milliseconds: 300));
      
      // Verify button is disabled for invalid input
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Test valid input
      await tester.enterText(find.byType(TextField), 'Smith');
      await tester.pump(const Duration(milliseconds: 300));
      
      // Verify button is enabled for valid input
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('handles special characters in last names correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final validNames = [
        'O\'Connor',
        'Smith-Jones',
        'García',
        'von Neumann',
        'de la Rosa',
      ];

      for (final name in validNames) {
        await tester.enterText(find.byType(TextField), name);
        await tester.pump();
        expect(find.text('Please enter a valid name'), findsNothing);
      }
    });

    testWidgets('navigates to EmailScreen on valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LastNameScreen(),
          routes: {
            '/email': (context) => const EmailScreen(),
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'Smith');
      await tester.pump(const Duration(milliseconds: 300));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(EmailScreen), findsOneWidget);
    });

    testWidgets('back button navigates to FirstNameScreen', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(FirstNameScreen), findsOneWidget);
    });

    testWidgets('next button is initially disabled', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isFalse);
    });

    testWidgets('next button enables when valid text is entered', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.enterText(find.byType(TextField), 'Smith');
      await tester.pump(const Duration(milliseconds: 300)); // Wait for debounce

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isTrue);
    });

    testWidgets('autofocuses text field on screen load', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('saves input value correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      const testValue = 'Smith';
      await tester.enterText(find.byType(TextField), testValue);
      await tester.pump();

      expect(find.text(testValue), findsOneWidget);
    });
  });
} 