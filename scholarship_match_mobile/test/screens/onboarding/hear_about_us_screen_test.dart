import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/hear_about_us_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/location_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/referral_code_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';

void main() {
  group('HearAboutUsScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const HearAboutUsScreen(),
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
      expect(find.text('How did you hear\nabout us?'), findsOneWidget);
      expect(
        find.text('This helps us understand how students find Grantly.'),
        findsOneWidget,
      );

      // Verify all options are present
      final expectedOptions = [
        'Social Media',
        'Friend or Family',
        'School Counselor',
        'Teacher',
        'College Advisor',
        'Search Engine',
        'App Store',
        'Other',
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

    testWidgets('navigates back to LocationScreen on back button tap',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(LocationScreen), findsOneWidget);
      expect(find.byType(HearAboutUsScreen), findsNothing);
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
        find.text('Social Media'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Social Media'));
      await tester.pumpAndSettle();

      // Next button should be enabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('navigates to ReferralCodeScreen when option is selected',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Scroll to and select an option
      await tester.dragUntilVisible(
        find.text('Social Media'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Social Media'));
      await tester.pumpAndSettle();

      // Tap next button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(ReferralCodeScreen), findsOneWidget);
      expect(find.byType(HearAboutUsScreen), findsNothing);
    });

    testWidgets('only one option can be selected at a time',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select first option
      await tester.dragUntilVisible(
        find.text('Social Media'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Social Media'));
      await tester.pumpAndSettle();

      // Verify first option is selected
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'Social Media'),
            )
            .isSelected,
        isTrue,
      );

      // Select second option
      await tester.dragUntilVisible(
        find.text('Friend or Family'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.tap(find.text('Friend or Family'));
      await tester.pumpAndSettle();

      // Verify second option is selected and first is deselected
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'Friend or Family'),
            )
            .isSelected,
        isTrue,
      );
      expect(
        tester
            .widget<SelectionButton>(
              find.widgetWithText(SelectionButton, 'Social Media'),
            )
            .isSelected,
        isFalse,
      );
    });
  });
} 