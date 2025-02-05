import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('FirstNameScreen', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const TestWrapper(
          child: FirstNameScreen(),
        ),
      );
      await tester.pump();
      // Wait for the focus timer
      await tester.pump(const Duration(milliseconds: 500));
    }

    tearDown(() async {
      // Remove this tearDown since we'll handle it in each test
    });

    testWidgets('renders title and subtitle correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      
      expect(find.text('What\'s your first name?'), findsOneWidget);
      expect(find.text('We\'ll use this to find scholarships.'), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('shows text field with correct hint', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstNameScreen()));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter your first name'), findsOneWidget);
    });

    testWidgets('validates input correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Find the TextField
      final textField = find.byType(TextField);

      // Test empty input
      await tester.enterText(textField, '');
      await tester.pump(const Duration(milliseconds: 300)); // Wait for debounce
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Test invalid input
      await tester.enterText(textField, '123');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Please enter a valid name'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Test valid input
      await tester.enterText(textField, 'John');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Please enter a valid name'), findsNothing);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('navigates to LastNameScreen on valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const FirstNameScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/last_name':
                return MaterialPageRoute(builder: (_) => const LastNameScreen());
              default:
                return null;
            }
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump(const Duration(milliseconds: 300));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(LastNameScreen), findsOneWidget);
    });

    testWidgets('saves input value correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const TestWrapper(
          child: FirstNameScreen(),
        ),
      );
      await tester.pumpAndSettle();

      const testValue = 'John';
      await tester.enterText(find.byType(TextField), testValue);
      await tester.pumpAndSettle();

      expect(find.text(testValue), findsOneWidget);
    });

    testWidgets('next button is initially disabled', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const TestWrapper(
          child: FirstNameScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isFalse);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('next button enables when valid text is entered', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump(const Duration(milliseconds: 300)); // Wait for debounce

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isTrue);
    });

    testWidgets('TextField autofocuses on screen load', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstNameScreen()));
      await tester.pump(const Duration(milliseconds: 500)); // Wait for autofocus

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('TextField shows error for invalid input', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.enterText(find.byType(TextField), '123');
      await tester.pump(const Duration(milliseconds: 300)); // Wait for debounce

      expect(find.text('Please enter a valid name'), findsOneWidget);
    });

    testWidgets('TextField updates when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstNameScreen()));

      const testValue = 'John';
      await tester.enterText(find.byType(TextField), testValue);
      await tester.pump();

      expect(find.text(testValue), findsOneWidget);
    });
  });
} 