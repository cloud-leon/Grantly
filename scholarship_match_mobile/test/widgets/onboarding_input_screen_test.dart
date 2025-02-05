import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'dart:ui' as ui;

void main() {
  group('OnboardingInputScreen', () {
    Widget createTestWidget({
      String title = 'Test Title',
      String subtitle = 'Test Subtitle',
      Widget? inputField,
      Widget? previousScreen,
      VoidCallback? onNext,
      bool isNextEnabled = true,
    }) {
      return MaterialApp(
        home: OnboardingInputScreen(
          title: title,
          subtitle: subtitle,
          inputField: inputField ?? const TextField(),
          previousScreen: previousScreen ?? const SizedBox(),
          onNext: onNext ?? () {},
          isNextEnabled: isNextEnabled,
        ),
      );
    }

    testWidgets('renders all basic components', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('back button navigates to previous screen', (WidgetTester tester) async {
      final previousScreen = Container(key: const Key('previous_screen'));
      
      await tester.pumpWidget(createTestWidget(
        previousScreen: previousScreen,
      ));

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('previous_screen')), findsOneWidget);
    });

    testWidgets('next button is disabled when isNextEnabled is false', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        isNextEnabled: false,
      ));

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isFalse);
    });

    testWidgets('next button is enabled when isNextEnabled is true', (WidgetTester tester) async {
      bool nextPressed = false;
      
      await tester.pumpWidget(createTestWidget(
        isNextEnabled: true,
        onNext: () => nextPressed = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      expect(nextPressed, isTrue);
    });

    testWidgets('custom input field is rendered', (WidgetTester tester) async {
      final customInput = Container(
        key: const Key('custom_input'),
        child: const TextField(decoration: InputDecoration(hintText: 'Custom Input')),
      );

      await tester.pumpWidget(createTestWidget(
        inputField: customInput,
      ));

      expect(find.byKey(const Key('custom_input')), findsOneWidget);
      expect(find.text('Custom Input'), findsOneWidget);
    });

    testWidgets('handles long titles correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(
        title: 'Very Long Title That Should Still Display Correctly Without Overflowing',
      ));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('maintains proper layout on small screens', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(320, 480);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('handles keyboard appearance correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Simulate keyboard appearance using MediaQuery
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            viewInsets: EdgeInsets.only(bottom: 500),
          ),
          child: createTestWidget(),
        ),
      );
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
} 