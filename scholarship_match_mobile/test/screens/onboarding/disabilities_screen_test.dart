import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/disabilities_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/race_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_gen_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('DisabilitiesScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: DisabilitiesScreen(),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Verify title and subtitle
      expect(
        find.text('Do you have any\ndisabilities?'),
        findsOneWidget,
      );
      expect(
        find.text('We will use this to find disability-specific scholarships.'),
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

      // Verify number of SelectionButtons matches options
      expect(find.byType(SelectionButton), findsNWidgets(expectedOptions.length));
    });

    testWidgets('navigates to FirstGenScreen on next', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select an option
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Tap next button
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.byType(FirstGenScreen), findsOneWidget);
    });

    testWidgets('navigates to RaceScreen on back', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(RaceScreen), findsOneWidget);
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

      // Initially not selected
      final initialButton = tester.widget<SelectionButton>(
        find.widgetWithText(SelectionButton, 'Yes'),
      );
      expect(initialButton.isSelected, isFalse);

      // Tap option
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Should be selected
      final selectedButton = tester.widget<SelectionButton>(
        find.widgetWithText(SelectionButton, 'Yes'),
      );
      expect(selectedButton.isSelected, isTrue);
    });

    testWidgets('only one option can be selected at a time', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select first option
      await tester.tap(find.text('Yes'));
      await tester.pump();

      // Select second option
      await tester.tap(find.text('No'));
      await tester.pump();

      // First option should be deselected
      expect(
        tester.widget<SelectionButton>(
          find.widgetWithText(SelectionButton, 'Yes'),
        ).isSelected,
        isFalse,
      );

      // Second option should be selected
      expect(
        tester.widget<SelectionButton>(
          find.widgetWithText(SelectionButton, 'No'),
        ).isSelected,
        isTrue,
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