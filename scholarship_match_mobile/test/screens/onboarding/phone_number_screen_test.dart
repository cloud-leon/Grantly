import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('PhoneNumberScreen', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const TestWrapper(
          child: PhoneNumberScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      
      expect(find.text('What\'s your phone number?'), findsOneWidget);
      expect(find.text('We\'ll text you about new matches.'), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('shows text field with correct hint', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('(555) 555-5555'), findsOneWidget);
    });

    testWidgets('validates phone number format correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Test invalid input
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump(const Duration(milliseconds: 300));

      // Verify error message appears
      expect(find.text('Please enter a valid 10-digit phone number'), findsOneWidget);

      // Test valid input
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.pump(const Duration(milliseconds: 300));

      // Verify error message disappears
      expect(find.text('Please enter a valid 10-digit phone number'), findsNothing);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('formats phone number correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.pump(const Duration(milliseconds: 300)); // Wait for debounce

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '(123) 456-7890');
    });

    testWidgets('navigates to DOBScreen on valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const PhoneNumberScreen(),
          routes: {
            '/dob': (context) => const DOBScreen(),
          },
        ),
      );

      await tester.enterText(find.byType(TextField), '(555) 555-5555');
      await tester.pump(const Duration(milliseconds: 300));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(DOBScreen), findsOneWidget);
    });

    testWidgets('back button navigates to EmailScreen', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(EmailScreen), findsOneWidget);
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

    testWidgets('shows country code picker with search functionality',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially shows US
      expect(find.text('US'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);

      // Tap to open country picker
      await tester.tap(find.text('US'));
      await tester.pumpAndSettle();

      // Check if country picker is shown with search bar
      expect(find.text('Select a Country Code'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search country'), findsOneWidget);

      // Test search functionality
      await tester.enterText(find.widgetWithText(TextField, 'Search country'), 'alb');
      await tester.pump();

      // Should show Albania but not Afghanistan
      expect(find.text('Albania'), findsOneWidget);
      expect(find.text('Afghanistan'), findsNothing);

      // Select Albania
      await tester.tap(find.text('Albania'));
      await tester.pumpAndSettle();

      // Check if selection is updated
      expect(find.text('AL'), findsOneWidget);
      expect(find.text('+355'), findsOneWidget);
    });

    testWidgets('country search works with country codes',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Open country picker
      await tester.tap(find.text('US'));
      await tester.pumpAndSettle();

      // Search by country code
      await tester.enterText(find.widgetWithText(TextField, 'Search country'), '+93');
      await tester.pump();

      // Should show Afghanistan
      expect(find.text('Afghanistan'), findsOneWidget);
      expect(find.text('Albania'), findsNothing);
    });

    testWidgets('country search bar is focused and input is visible',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Open country picker
      await tester.tap(find.text('US'));
      await tester.pumpAndSettle();

      // Find search TextField
      final searchField = find.widgetWithText(TextField, 'Search country');
      
      // Verify search field is focused
      expect(
        (tester.widget(searchField) as TextField).focusNode?.hasFocus,
        isTrue,
      );

      // Enter text and verify it's visible
      await tester.enterText(searchField, 'test input');
      await tester.pump();

      // Find the input text with black color
      final searchText = tester.widget<TextField>(searchField);
      expect(searchText.style?.color, Colors.black);
      expect(find.text('test input'), findsOneWidget);
    });
  });
} 