import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';

void main() {
  group('SelectionScreen', () {
    final options = ['Option 1', 'Option 2', 'Option 3'];
    String? selectedValue;

    Widget buildTestWidget() {
      return MaterialApp(
        home: SelectionScreen(
          title: 'Test Title',
          subtitle: 'Test Subtitle',
          options: options,
          previousScreen: const Scaffold(),
          onNext: (value) => selectedValue = value,
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Verify basic elements
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

      // Verify all options are rendered
      for (final option in options) {
        expect(find.text(option), findsOneWidget);
      }

      // Verify number of SelectionButtons matches options
      expect(find.byType(SelectionButton), findsNWidgets(options.length));
    });

    testWidgets('next button is initially disabled', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('selecting an option enables next button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap first option
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping option updates selection', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Initially no selection
      expect(
        tester.widget<SelectionButton>(
          find.byWidgetPredicate(
            (widget) => widget is SelectionButton && widget.text == 'Option 1',
          ),
        ).isSelected,
        false,
      );

      // Tap first option
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      // Verify selection updated
      expect(
        tester.widget<SelectionButton>(
          find.byWidgetPredicate(
            (widget) => widget is SelectionButton && widget.text == 'Option 1',
          ),
        ).isSelected,
        true,
      );
    });

    testWidgets('next button calls onNext with selected value', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Select an option
      await tester.tap(find.text('Option 1'));
      await tester.pump();

      // Tap next button
      await tester.tap(find.text('NEXT'));
      await tester.pump();

      expect(selectedValue, equals('Option 1'));
    });

    testWidgets('back button navigates to previous screen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.byType(SelectionScreen), findsNothing);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('has correct gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

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