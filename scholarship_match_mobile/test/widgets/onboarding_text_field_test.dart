import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';

void main() {
  group('OnboardingTextField', () {
    late TextEditingController controller;
    late FocusNode focusNode;

    setUp(() {
      controller = TextEditingController();
      focusNode = FocusNode();
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    Widget buildTestWidget({
      String? errorText,
      TextInputType? keyboardType,
      TextInputAction? textInputAction,
      ValueChanged<String>? onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OnboardingTextField(
            controller: controller,
            focusNode: focusNode,
            hintText: 'Test Hint',
            errorText: errorText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('shows error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(errorText: 'Test Error'));

      expect(find.text('Test Error'), findsOneWidget);
    });

    testWidgets('has correct text style', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.color, Colors.white);
    });

    testWidgets('has correct decoration styles', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration as InputDecoration;

      // Test enabled border
      final enabledBorder = decoration.enabledBorder as UnderlineInputBorder;
      expect(enabledBorder.borderSide.color, Colors.white);

      // Test focused border
      final focusedBorder = decoration.focusedBorder as UnderlineInputBorder;
      expect(focusedBorder.borderSide.color, Colors.white);

      // Test error border
      final errorBorder = decoration.errorBorder as UnderlineInputBorder;
      expect(errorBorder.borderSide.color, Colors.red);

      // Test focused error border
      final focusedErrorBorder = decoration.focusedErrorBorder as UnderlineInputBorder;
      expect(focusedErrorBorder.borderSide.color, Colors.red);

      // Test hint style
      expect(decoration.hintStyle?.color, Colors.white.withOpacity(0.5));

      // Test error style
      expect(decoration.errorStyle?.color, Colors.red);
    });

    testWidgets('handles text input', (WidgetTester tester) async {
      String? changedText;
      await tester.pumpWidget(
        buildTestWidget(onChanged: (value) => changedText = value),
      );

      await tester.enterText(find.byType(TextField), 'Test Input');
      expect(controller.text, 'Test Input');
      expect(changedText, 'Test Input');
    });

    testWidgets('uses correct keyboard type', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(keyboardType: TextInputType.number),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('uses correct text input action', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(textInputAction: TextInputAction.done),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, TextInputAction.done);
    });

    testWidgets('focus works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(focusNode.hasFocus, false);
      
      await tester.tap(find.byType(TextField));
      await tester.pump();
      
      expect(focusNode.hasFocus, true);
    });

    testWidgets('controller updates text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      controller.text = 'Test Controller';
      await tester.pump();

      expect(find.text('Test Controller'), findsOneWidget);
    });
  });
} 