import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/welcome_onboard_screen.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('WelcomeOnboardScreen', () {
    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const WelcomeOnboardScreen(),
              );
            },
          ),
        ),
      );
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      await tester.pumpAndSettle(); // Wait for any animations

      // Verify logo text
      expect(find.text('Grantly'), findsOneWidget);

      // Verify welcome text
      expect(find.text("Let's find your next scholarship!"), findsOneWidget);

      // Verify commitment section
      expect(find.text('Our Commitment'), findsOneWidget);

      // Verify bullet points
      expect(
        find.text('We want to help you find scholarships that you will likely win'),
        findsOneWidget,
      );
      expect(
        find.text('We think applying to scholarships should be easier'),
        findsOneWidget,
      );
      expect(
        find.text('We\'re here to make that happen 👇'),
        findsOneWidget,
      );

      // Verify button
      expect(find.widgetWithText(ElevatedButton, 'Get Started'), findsOneWidget);

      // Find the terms RichText by its unique properties
      final termsRichText = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final text = widget.text.toPlainText();
          return text.contains('By continuing, you agree to our') &&
                 text.contains('Terms') &&
                 text.contains('Privacy Policy');
        }
        return false;
      });
      expect(termsRichText, findsOneWidget);
    });

    testWidgets('has correct gradient background', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      await tester.pumpAndSettle();

      // Find the outermost Container with gradient
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
    });

    testWidgets('navigates to FirstNameScreen on Get Started tap', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      await tester.pumpAndSettle();

      // Scroll to make the button visible
      await tester.dragUntilVisible(
        find.widgetWithText(ElevatedButton, 'Get Started'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // Tap the button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(FirstNameScreen), findsOneWidget);
    });

    testWidgets('terms text is clickable', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      await tester.pumpAndSettle();

      // Find the terms RichText by its unique content
      final richTextFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final text = widget.text.toPlainText();
          return text.contains('By continuing, you agree to our') &&
                 text.contains('Terms') &&
                 text.contains('Privacy Policy');
        }
        return false;
      });
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final span = richText.text as TextSpan;
      
      // Find Terms and Privacy Policy spans
      final spans = span.children!;
      final termsSpan = spans.firstWhere(
        (span) => span is TextSpan && span.text == 'Terms',
      ) as TextSpan;
      final privacySpan = spans.firstWhere(
        (span) => span is TextSpan && span.text == 'Privacy Policy',
      ) as TextSpan;

      expect(termsSpan.recognizer, isNotNull);
      expect(privacySpan.recognizer, isNotNull);
    });

    testWidgets('bullet points are properly formatted', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      await tester.pumpAndSettle();

      // Find bullet point rows that contain bullet points
      final bulletPointRows = tester.widgetList<Row>(
        find.byWidgetPredicate((widget) {
          if (widget is Row) {
            return widget.children.length == 2 &&
                   widget.children.first is Text &&
                   (widget.children.first as Text).data == '•  ';
          }
          return false;
        }),
      );

      expect(bulletPointRows.length, 3, reason: 'Should have exactly 3 bullet points');

      for (final row in bulletPointRows) {
        final children = row.children;
        expect(children.length, 2, reason: 'Each bullet point should have 2 children');
        expect(children.first, isA<Text>(), reason: 'First child should be bullet point');
        expect(children.last, isA<Expanded>(), reason: 'Second child should be expanded text');
      }
    });
  });
} 