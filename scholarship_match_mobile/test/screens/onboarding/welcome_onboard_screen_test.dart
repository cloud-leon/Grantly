import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/welcome_onboard_screen.dart';

void main() {
  group('WelcomeOnboardScreen', () {
    testWidgets('displays all elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: WelcomeOnboardScreen(),
      ));

      expect(find.text('Grantly'), findsOneWidget);
      expect(
        find.text('Let your next scholarship opportunity find You!'),
        findsOneWidget,
      );
      expect(
        find.text("We'll ask you a few questions to find the best scholarships for you This should take about 2 minutes"),
        findsOneWidget,
      );
      expect(
        find.text("We think applying to scholarships should be easier"),
        findsOneWidget,
      );
      expect(
        find.text("We're here to make that happen 👇"),
        findsOneWidget,
      );
      expect(find.text('GET STARTED'), findsOneWidget);
    });

    testWidgets('Get Started button triggers navigation', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        home: const WelcomeOnboardScreen(),
      ));

      final button = find.text('GET STARTED');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      // Verify that we're on the FirstNameScreen
      final firstNameScreen = find.byType(FirstNameScreen);
      expect(firstNameScreen, findsOneWidget);
    });
  });
} 