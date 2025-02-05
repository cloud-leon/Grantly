import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('CitizenshipScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: CitizenshipScreen(),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Verify title and subtitle
      expect(
        find.text('What is your\ncitizenship status?'),
        findsOneWidget,
      );
      expect(
        find.text('We will filter scholarships based on your citizenship status.'),
        findsOneWidget,
      );

      // Verify all citizenship options are present
      final expectedOptions = [
        'US Citizen',
        'US Permanent Resident',
        'International',
        'Other',
      ];

      for (final option in expectedOptions) {
        expect(find.text(option), findsOneWidget);
      }

      // Verify number of SelectionButtons matches options
      expect(find.byType(SelectionButton), findsNWidgets(expectedOptions.length));
    });

    testWidgets('navigates to GenderScreen on next', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Select an option
      await tester.tap(find.text('US Citizen'));
      await tester.pump();

      // Tap next button
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.byType(GenderScreen), findsOneWidget);
    });

    testWidgets('navigates to DOBScreen on back', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byType(DOBScreen), findsOneWidget);
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
      await tester.tap(find.text('US Citizen'));
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
        find.widgetWithText(SelectionButton, 'US Citizen'),
      );
      expect(initialButton.isSelected, isFalse);

      // Tap option
      await tester.tap(find.text('US Citizen'));
      await tester.pump();

      // Should be selected
      final selectedButton = tester.widget<SelectionButton>(
        find.widgetWithText(SelectionButton, 'US Citizen'),
      );
      expect(selectedButton.isSelected, isTrue);
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