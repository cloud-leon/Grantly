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

      // Test invalid input
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      expect(find.text('Please enter a valid name'), findsOneWidget);

      // Test valid input
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();
      expect(find.text('Please enter a valid name'), findsNothing);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('navigates to LastNameScreen on valid input', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();
      
      // Tap the next button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Pump once for the tap
      await tester.pump(const Duration(milliseconds: 500)); // Wait for navigation

      expect(find.byType(LastNameScreen), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
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
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(
        const TestWrapper(
          child: FirstNameScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isTrue);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('TextField autofocuses on screen load', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstNameScreen()));
      await tester.pump(const Duration(milliseconds: 500)); // Wait for autofocus

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('TextField shows error for invalid input', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstNameScreen()));

      // Enter invalid input (numbers)
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();

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