import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/disabilities_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/race_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('RaceScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const RaceScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Verify title and subtitle
      expect(find.text('Race?'), findsOneWidget);
      expect(
        find.text('We will select this race on your applications.'),
        findsOneWidget,
      );

      // Verify all race options are present
      final expectedOptions = [
        'White/Caucasian',
        'Black/African American',
        'Asian',
        'Hispanic',
        'Native American / Pacific Islander',
        'Two or more races',
        'Other',
        'Prefer not to say',
      ];

      for (final option in expectedOptions) {
        expect(find.text(option), findsOneWidget);
      }

      // Verify back button is present (using IconButton instead of Icon)
      expect(find.byType(IconButton), findsOneWidget);

      // Verify next button is present but disabled initially
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.enabled, isFalse);
    });

    testWidgets('navigates back to GenderScreen on back button tap',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Tap the IconButton instead of looking for the icon directly
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(GenderScreen), findsOneWidget);
      expect(find.byType(RaceScreen), findsNothing);
    });

    testWidgets('enables next button when option is selected',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially next button should be disabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Scroll to and select an option
      await tester.dragUntilVisible(
        find.text('White/Caucasian'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('White/Caucasian'));
      await tester.pumpAndSettle();

      // Next button should be enabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('navigates to DisabilitiesScreen when option is selected',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select an option
      await tester.dragUntilVisible(
        find.text('White/Caucasian'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('White/Caucasian'));
      await tester.pumpAndSettle();

      // Tap next button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(DisabilitiesScreen), findsOneWidget);
      expect(find.byType(RaceScreen), findsNothing);
    });

    testWidgets('only one option can be selected at a time',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select first option
      await tester.dragUntilVisible(
        find.text('White/Caucasian'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('White/Caucasian'));
      await tester.pumpAndSettle();

      // Verify first option is selected
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'White/Caucasian'),
            )
            .isSelected,
        isTrue,
      );

      // Select second option
      await tester.dragUntilVisible(
        find.text('Black/African American'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Black/African American'));
      await tester.pumpAndSettle();

      // Verify second option is selected and first is deselected
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'Black/African American'),
            )
            .isSelected,
        isTrue,
      );
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'White/Caucasian'),
            )
            .isSelected,
        isFalse,
      );
    });
  });
} 