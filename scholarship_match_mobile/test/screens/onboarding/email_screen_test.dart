import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import '../../helpers/test_wrapper.dart';

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

    testWidgets('validates email format correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Test invalid emails
      final invalidEmails = [
        '',
        'notanemail',
        'missing@domain',
        '@nodomain.com',
        'spaces in@email.com',
        'missing.domain@.com',
      ];

      for (final email in invalidEmails) {
        await tester.enterText(find.byType(TextField), email);
        await tester.pump();

        if (email.isNotEmpty) {
          expect(find.text('Please enter a valid email address'), findsOneWidget);
        }
        
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.enabled, isFalse);
      }

      // Test valid emails
      final validEmails = [
        'test@example.com',
        'user.name@domain.com',
        'user+tag@domain.co.uk',
        'valid@subdomain.domain.com',
      ];

      for (final email in validEmails) {
        await tester.enterText(find.byType(TextField), email);
        await tester.pump();

        expect(find.text('Please enter a valid email address'), findsNothing);
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.enabled, isTrue);
      }

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('navigates to PhoneNumberScreen on valid input', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await pumpTestWidget(tester);

        await tester.enterText(find.byType(TextField), 'test@example.com');
        await tester.pump();
        
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(PhoneNumberScreen), findsOneWidget);

        addTearDown(() async {
          await tester.binding.setSurfaceSize(null);
        });
      });
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