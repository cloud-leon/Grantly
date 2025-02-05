import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import '../../helpers/test_wrapper.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';

void main() {
  group('EmailScreen', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const TestWrapper(
          child: EmailScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      
      expect(find.text('What\'s your email?'), findsOneWidget);
      expect(find.text('We\'ll send you scholarship matches here.'), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('shows text field with correct hint', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('validates input correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Find the TextField
      final textField = find.byType(OnboardingTextField);

      // Test empty input
      await tester.enterText(textField, '');
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Test invalid input
      await tester.enterText(textField, 'invalid-email');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Test valid input
      await tester.enterText(textField, 'test@example.com');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('navigates to PhoneNumberScreen on valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const EmailScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/phone') {
              return MaterialPageRoute(
                builder: (_) => const PhoneNumberScreen(),
                settings: settings,
              );
            }
            return null;
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump(const Duration(milliseconds: 300));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneNumberScreen), findsOneWidget);
    });

    testWidgets('back button navigates to LastNameScreen', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(LastNameScreen), findsOneWidget);
    });

    testWidgets('next button is initially disabled', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isFalse);
    });

    testWidgets('autofocuses text field on screen load', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('saves input value correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      const testValue = 'test@example.com';
      await tester.enterText(find.byType(TextField), testValue);
      await tester.pump();

      expect(find.text(testValue), findsOneWidget);
    });
  });
} 