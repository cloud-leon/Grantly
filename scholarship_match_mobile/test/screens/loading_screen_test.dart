import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/loading_screen.dart';

void main() {
  group('LoadingScreen', () {
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: const LoadingScreen(),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
      );
    }

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('displays Grantly text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify Grantly text is displayed and styled correctly
      expect(find.text('Grantly'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('Grantly'));
      final textStyle = textWidget.style!;
      
      expect(textStyle.color, Colors.white);
      expect(textStyle.fontWeight, FontWeight.bold);
      expect(textStyle.letterSpacing, -0.5);
      expect(textWidget.textAlign, TextAlign.center);

      // Handle the pending timer
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('navigates to login screen after delay', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify initial state
      expect(find.text('Grantly'), findsOneWidget);
      expect(find.text('Login Screen'), findsNothing);

      // Wait for the navigation delay
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      
      // Wait for navigation animation to complete
      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.text('Login Screen'), findsOneWidget);
      expect(find.text('Grantly'), findsNothing);
    });

    testWidgets('has correct gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the Container with gradient
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;

      // Verify gradient properties
      expect(gradient.begin, Alignment.topRight);
      expect(gradient.end, Alignment.bottomLeft);
      expect(gradient.colors, [
        const Color(0xFF7B4DFF), // Deep purple
        const Color(0xFF4D9FFF), // Light blue
      ]);

      // Verify the container is wrapped in a Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);

      // Handle the pending timer
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
} 