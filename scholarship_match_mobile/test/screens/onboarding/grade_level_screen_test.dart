import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/grade_level_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/military_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/location_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('GradeLevelScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1500));
      await tester.pumpWidget(
        const TestWrapper(
          child: GradeLevelScreen(),
        ),
      );
    }

    Future<void> tapOption(WidgetTester tester, String option) async {
      final finder = find.widgetWithText(SelectionButton, option);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder, warnIfMissed: false);
      await tester.pump();
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Verify title and subtitle
      expect(
        find.text('What is your current\ngrade in school?'),
        findsOneWidget,
      );
      expect(
        find.text('We will use this to find grade-specific scholarships.'),
        findsOneWidget,
      );

      // Verify all options are present
      final expectedOptions = [
        'Not Currently Enrolled/Non-Traditional Student',
        'Pre-High School',
        'High School Freshman (Class of 2028)',
        'High School Sophomore (Class of 2027)',
        'High School Junior (Class of 2026)',
        'High School Senior (Class of 2025)',
        'College Freshman (Class of 2028)',
        'College Sophomore (Class of 2027)',
        'College Junior (Class of 2026)',
        'College Senior (Class of 2025)',
        'Graduate School 1st Year',
        'Graduate School 2nd Year',
        'Graduate School 3rd Year',
        'Graduate School 4th Year',
        'Trade/Tech/Career Student',
      ];

      for (final option in expectedOptions) {
        expect(find.text(option), findsOneWidget);
      }

      // Verify number of SelectionButtons matches options
      expect(find.byType(SelectionButton), findsNWidgets(expectedOptions.length));

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('navigates to LocationScreen on next', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select an option
      await tapOption(tester, 'College Freshman (Class of 2028)');

      // Tap next button
      await tester.tap(find.text('NEXT'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(LocationScreen), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('navigates to MilitaryScreen on back', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(MilitaryScreen), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('next button is initially disabled', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('next button enables when option is selected', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially disabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Select an option
      await tapOption(tester, 'College Freshman (Class of 2028)');

      // Should be enabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('selection updates correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      const option = 'College Freshman (Class of 2028)';

      // Initially not selected
      final initialButton = tester.widget<SelectionButton>(
        find.widgetWithText(SelectionButton, option),
      );
      expect(initialButton.isSelected, isFalse);

      // Tap option
      await tapOption(tester, option);

      // Should be selected
      final selectedButton = tester.widget<SelectionButton>(
        find.widgetWithText(SelectionButton, option),
      );
      expect(selectedButton.isSelected, isTrue);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('only one option can be selected at a time', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      const firstOption = 'College Freshman (Class of 2028)';
      const secondOption = 'College Senior (Class of 2025)';

      // Select first option
      await tapOption(tester, firstOption);

      // Select second option
      await tapOption(tester, secondOption);

      // First option should be deselected
      expect(
        tester.widget<SelectionButton>(
          find.widgetWithText(SelectionButton, firstOption),
        ).isSelected,
        isFalse,
      );

      // Second option should be selected
      expect(
        tester.widget<SelectionButton>(
          find.widgetWithText(SelectionButton, secondOption),
        ).isSelected,
        isTrue,
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('scrolls to show all options', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Verify first option is visible
      expect(
        find.text('Not Currently Enrolled/Non-Traditional Student'),
        findsOneWidget,
      );

      // Scroll to bottom
      await tester.dragFrom(
        tester.getCenter(find.byType(SingleChildScrollView)),
        const Offset(0, -500),
      );
      await tester.pump();

      // Verify last option is now visible
      expect(
        find.text('Trade/Tech/Career Student'),
        findsOneWidget,
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('has correct gradient background', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration != null,
        ).first,
      );

      final gradient = (container.decoration as BoxDecoration).gradient as LinearGradient;
      
      expect(gradient.colors, [
        const Color(0xFF7B4DFF),
        const Color(0xFF4D9FFF),
      ]);
      expect(gradient.begin, Alignment.topRight);
      expect(gradient.end, Alignment.bottomLeft);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
} 