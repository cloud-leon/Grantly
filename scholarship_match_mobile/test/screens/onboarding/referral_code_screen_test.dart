import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/hear_about_us_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/referral_code_screen.dart';

void main() {
  group('ReferralCodeScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const ReferralCodeScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Verify title text
      expect(find.text('Do you have a\nreferral code?'), findsOneWidget);

      // Verify skip text
      expect(find.text('You can skip this step.'), findsOneWidget);

      // Verify text field with hint
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('X5F124'), findsOneWidget);

      // Verify back button
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

      // Verify button shows SKIP initially
      expect(find.widgetWithText(ElevatedButton, 'SKIP'), findsOneWidget);
    });

    testWidgets('navigates back to HearAboutUsScreen on back button tap',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(HearAboutUsScreen), findsOneWidget);
      expect(find.byType(ReferralCodeScreen), findsNothing);
    });

    testWidgets('button text changes based on text field input',
        (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially shows SKIP
      expect(find.widgetWithText(ElevatedButton, 'SKIP'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'DONE'), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'TEST123');
      await tester.pump();

      // Should now show DONE
      expect(find.widgetWithText(ElevatedButton, 'DONE'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'SKIP'), findsNothing);

      // Clear text
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Should show SKIP again
      expect(find.widgetWithText(ElevatedButton, 'SKIP'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'DONE'), findsNothing);
    });

    testWidgets('text field styling is correct', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final textField = tester.widget<TextField>(find.byType(TextField));

      // Verify text style
      expect(textField.style?.color, Colors.white);
      expect(textField.style?.fontSize, 20);

      // Verify decoration
      final decoration = textField.decoration as InputDecoration;
      expect(decoration.hintText, 'X5F124');
      expect(decoration.hintStyle?.color, Colors.white.withOpacity(0.3));
      expect(decoration.hintStyle?.fontSize, 20);

      // Verify border styling
      final enabledBorder = decoration.enabledBorder as UnderlineInputBorder;
      expect(
        enabledBorder.borderSide.color,
        Colors.white.withOpacity(0.5),
      );

      final focusedBorder = decoration.focusedBorder as UnderlineInputBorder;
      expect(focusedBorder.borderSide.color, Colors.white);
    });

    testWidgets('gradient background is correct', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final container = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final decoration = widget.decoration as BoxDecoration?;
            return decoration?.gradient != null;
          }
          return false;
        }).first,
      );

      final gradient = (container.decoration as BoxDecoration).gradient as LinearGradient;

      expect(gradient.colors, [
        const Color(0xFF7B4DFF),
        const Color(0xFF4D9FFF),
      ]);
      expect(gradient.begin, Alignment.topRight);
      expect(gradient.end, Alignment.bottomLeft);
      expect(gradient.stops, [0.0, 1.0]);
    });

    testWidgets('disposes controller properly', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Enter some text
      await tester.enterText(find.byType(TextField), 'TEST123');
      await tester.pump();

      // Rebuild with a different widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // No errors should be thrown
      expect(tester.takeException(), isNull);
    });
  });
} 