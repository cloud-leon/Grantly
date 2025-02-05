import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';

void main() {
  group('SelectionButton', () {
    testWidgets('renders correctly when not selected', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionButton(
              text: 'Test Button',
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Verify appearance
      final button = find.byType(SelectionButton);
      expect(button, findsOneWidget);
      
      // Verify text
      expect(find.text('Test Button'), findsOneWidget);
      
      // Verify container styling
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(
        (decoration.border as Border).top.color, 
        Colors.white.withOpacity(0.5),
      );

      // Verify text styling
      final text = tester.widget<Text>(find.text('Test Button'));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('renders correctly when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionButton(
              text: 'Test Button',
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify container styling
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
      expect((decoration.border as Border).top.color, Colors.white);

      // Verify text styling
      final text = tester.widget<Text>(find.text('Test Button'));
      expect(text.style?.color, Colors.black);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionButton(
              text: 'Test Button',
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SelectionButton));
      expect(tapped, true);
    });
  });
} 