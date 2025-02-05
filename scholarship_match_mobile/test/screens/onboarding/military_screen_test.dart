import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/financial_aid_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/grade_level_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/military_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';

void main() {
  group('MilitaryScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const MilitaryScreen(),
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
      expect(find.text('Are you interested in\nmilitary opportunities?'), findsOneWidget);
      expect(
        find.text('We will use this to find military-related scholarships.'),
        findsOneWidget,
      );

      // Verify all options are present
      final expectedOptions = [
        'Yes',
        'No',
        'Prefer not to say',
      ];

      for (final option in expectedOptions) {
        expect(find.text(option), findsOneWidget);
      }

      // Verify back button is present
      expect(find.byType(IconButton), findsOneWidget);

      // Verify next button is present but disabled initially
      final nextButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(nextButton.enabled, isFalse);
    });

    testWidgets('navigates back to FinancialAidScreen on back button tap',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(FinancialAidScreen), findsOneWidget);
      expect(find.byType(MilitaryScreen), findsNothing);
    });

    testWidgets('enables next button when option is selected',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially next button should be disabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Select an option
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Next button should be enabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('navigates to GradeLevelScreen when option is selected',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select an option
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Tap next button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(GradeLevelScreen), findsOneWidget);
      expect(find.byType(MilitaryScreen), findsNothing);
    });

    testWidgets('only one option can be selected at a time',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select first option
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Verify first option is selected
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'Yes'),
            )
            .isSelected,
        isTrue,
      );

      // Select second option
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      // Verify second option is selected and first is deselected
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'No'),
            )
            .isSelected,
        isTrue,
      );
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'Yes'),
            )
            .isSelected,
        isFalse,
      );
    });
  });
} 