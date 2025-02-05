import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/other_source_bottom_sheet.dart';

void main() {
  group('OtherSourceBottomSheet', () {
    late List<MethodCall> systemChannelCalls;

    setUp(() {
      systemChannelCalls = <MethodCall>[];
      SystemChannels.textInput.setMockMethodCallHandler((MethodCall methodCall) async {
        systemChannelCalls.add(methodCall);
        return null;
      });
    });

    tearDown(() {
      SystemChannels.textInput.setMockMethodCallHandler(null);
    });

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const OtherSourceBottomSheet(),
                );
              },
              child: const Text('Show Bottom Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Can you provide more details?'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'NEXT'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('text field has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const OtherSourceBottomSheet(),
                );
              },
              child: const Text('Show Bottom Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));

      // Verify text field properties
      expect(textField.autofocus, isTrue);
      expect(textField.keyboardType, TextInputType.text);
      expect(textField.textInputAction, TextInputAction.done);
      expect(textField.keyboardAppearance, Brightness.light);

      // Verify decoration
      final decoration = textField.decoration as InputDecoration;
      expect(decoration.hintText, 'Influencer, flyer, etc..');
      expect(decoration.border, isA<UnderlineInputBorder>());
      expect(decoration.focusedBorder, isA<UnderlineInputBorder>());
    });

    testWidgets('shows keyboard automatically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OtherSourceBottomSheet(),
          ),
        ),
      );

      // Wait for the delayed focus request
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Check if the TextField has focus
      final focusNode = tester.widget<TextField>(find.byType(TextField)).focusNode;
      expect(focusNode?.hasFocus, isTrue);
    });

    testWidgets('closes on back button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const OtherSourceBottomSheet(),
                );
              },
              child: const Text('Show Bottom Sheet'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is shown
      expect(find.byType(OtherSourceBottomSheet), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Verify bottom sheet is closed
      expect(find.byType(OtherSourceBottomSheet), findsNothing);
    });

    testWidgets('closes on downward swipe', (WidgetTester tester) async {
      bool bottomSheetDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const OtherSourceBottomSheet(),
                ).then((_) => bottomSheetDismissed = true);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Open the bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Find the drag handle (usually at the top of the sheet)
      final dragTarget = find.byType(Material).last;

      // Perform a fling gesture (faster than drag)
      await tester.fling(dragTarget, const Offset(0, 200), 1000.0);
      await tester.pumpAndSettle();

      // Verify the bottom sheet was dismissed
      expect(bottomSheetDismissed, isTrue, reason: 'Bottom sheet should be dismissed after fling');
    });

    testWidgets('navigates on NEXT button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/test',
          routes: {
            '/test': (context) => Scaffold(
                  body: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const OtherSourceBottomSheet(),
                        );
                      },
                      child: const Text('Show Bottom Sheet'),
                    ),
                  ),
                ),
            '/home': (context) => const Scaffold(body: Text('Home Screen')),
          },
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Show Bottom Sheet'));
      await tester.pumpAndSettle();

      // Tap NEXT button
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('adjusts for keyboard', (WidgetTester tester) async {
      // Set a fixed window size
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              viewInsets: EdgeInsets.only(bottom: 300),
              size: Size(400, 800),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      enableDrag: false,
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const OtherSourceBottomSheet(),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Find the NEXT button's padding
      final buttonPadding = tester.widget<Padding>(
        find.ancestor(
          of: find.widgetWithText(ElevatedButton, 'NEXT'),
          matching: find.byType(Padding),
        ).first,
      );

      // Verify the padding adjusts for keyboard
      final resolvedPadding = buttonPadding.padding.resolve(TextDirection.ltr);
      expect(resolvedPadding.bottom, greaterThanOrEqualTo(20));
    });
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  final void Function(Route<dynamic>, Route<dynamic>?) onPop;

  _TestNavigatorObserver({required this.onPop});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop(route, previousRoute);
    super.didPop(route, previousRoute);
  }
} 