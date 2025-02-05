import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_gen_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/disabilities_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/financial_aid_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('FirstGenScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: FirstGenScreen(),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Verify title and subtitle
      expect(
        find.text('Are you a\nfirst-generation student?'),
        findsOneWidget,
      );
      expect(
        find.text('We will use this to find first-generation specific scholarships.'),
        findsOneWidget,
      );

      // Verify all options are present
      final expectedOptions = [
        'Yes',
        'No',
        'I don\'t know',
        'Prefer not to say',
      ];

      for (final option in expectedOptions) {
        expect(find.text(option), findsOneWidget);
      }

      // Verify number of SelectionButtons matches options
      expect(find.byType(SelectionButton), findsNWidgets(expectedOptions.length));
    });

    testWidgets('navigates to FinancialAidScreen on next', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select an option
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Tap next button
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.byType(FinancialAidScreen), findsOneWidget);
    });

    testWidgets('navigates to DisabilitiesScreen on back', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(DisabilitiesScreen), findsOneWidget);
    });

    testWidgets('next button is initially disabled', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('next button enables when option is selected', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially disabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Select an option
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Should be enabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('selection updates correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      const option = 'Yes';
      final button = find.widgetWithText(SelectionButton, option);

      // Initially not selected
      expect(
        tester.widget<SelectionButton>(button).isSelected,
        isFalse,
      );

      // Tap option
      await tester.tap(button, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should be selected
      expect(
        tester.widget<SelectionButton>(button).isSelected,
        isTrue,
      );
    });

    testWidgets('only one option can be selected at a time', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      const firstOption = 'Yes';
      const secondOption = 'I don\'t know';

      // Get all buttons before any selection
      expect(
        tester.widgetList<SelectionButton>(find.byType(SelectionButton))
            .where((button) => button.isSelected)
            .length,
        0,
        reason: 'No buttons should be selected initially',
      );

      // Select first option
      await tester.tap(find.widgetWithText(SelectionButton, firstOption));
      await tester.pumpAndSettle();

      // Verify first option is selected
      final buttonsAfterFirst = tester.widgetList<SelectionButton>(find.byType(SelectionButton));
      final selectedAfterFirst = buttonsAfterFirst.where((button) => button.isSelected).toList();
      expect(selectedAfterFirst.length, 1, reason: 'Exactly one button should be selected');
      expect(selectedAfterFirst.first.text, firstOption, reason: 'First option should be selected');

      // Scroll to and select second option
      await tester.dragUntilVisible(
        find.widgetWithText(SelectionButton, secondOption),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SelectionButton, secondOption));
      await tester.pumpAndSettle();

      // Verify second option is selected and first is deselected
      final buttonsAfterSecond = tester.widgetList<SelectionButton>(find.byType(SelectionButton));
      final selectedAfterSecond = buttonsAfterSecond.where((button) => button.isSelected).toList();
      expect(selectedAfterSecond.length, 1, reason: 'Exactly one button should be selected');
      expect(selectedAfterSecond.first.text, secondOption, reason: 'Second option should be selected');
      expect(
        buttonsAfterSecond.firstWhere((button) => button.text == firstOption).isSelected,
        isFalse,
        reason: 'First option should be deselected',
      );
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
    });
  });
} 