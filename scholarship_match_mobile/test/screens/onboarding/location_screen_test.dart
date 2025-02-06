import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/location_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/grade_level_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/hear_about_us_screen.dart';

void main() {
  group('LocationScreen', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocationScreen()));

      // Check for main UI elements
      expect(find.text('Location?'), findsOneWidget);
      expect(find.text('Primary location'), findsOneWidget);
      expect(find.text('Houston, Texas, United States'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);
      expect(find.text('Continue later'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('navigates back on back button press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LocationScreen(),
          routes: {
            '/grade_level': (context) => const GradeLevelScreen(),
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(GradeLevelScreen), findsOneWidget);
    });

    testWidgets('navigates forward on DONE button press', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LocationScreen(),
          routes: {
            '/hear_about_us': (context) => const HearAboutUsScreen(),
          },
        ),
      );

      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();

      expect(find.byType(HearAboutUsScreen), findsOneWidget);
    });

    testWidgets('shows location search bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocationScreen()));

      // Open location search
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify bottom sheet content
      expect(find.text('Select a location'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Searching in United States'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('updates location on search completion', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocationScreen()));

      // Open location search
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Enter new location
      await tester.enterText(find.byType(TextField), 'New York, NY');
      await tester.pumpAndSettle();

      // Tap DONE
      await tester.tap(find.text('DONE').last);
      await tester.pumpAndSettle();

      // Verify location updated
      expect(find.text('New York, NY'), findsOneWidget);
    });

    testWidgets('dismisses search on cancel', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LocationScreen()));

      // Open location search
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'New York, NY');
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify original location remains
      expect(find.text('Houston, Texas, United States'), findsOneWidget);
      expect(find.text('New York, NY'), findsNothing);
    });

    testWidgets('adjusts for keyboard in search', (WidgetTester tester) async {
      // Build the widget with a fixed size and simulated keyboard
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 800),
              viewInsets: EdgeInsets.only(bottom: 300),
            ),
            child: const LocationScreen(),
          ),
        ),
      );

      // Open location search by tapping the edit icon
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify the bottom sheet content is visible and positioned correctly
      expect(find.text('Select a location'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Find the search text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Verify the text field is visible and usable
      await tester.enterText(textField, 'Test Location');
      await tester.pumpAndSettle();

      expect(find.text('Test Location'), findsOneWidget);
    });
  });
} 