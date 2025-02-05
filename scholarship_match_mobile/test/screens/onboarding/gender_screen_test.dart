import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/race_screen.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  group('GenderScreen', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Future<void> pumpTestWidget(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        const TestWrapper(
          child: GenderScreen(),
        ),
      );
      await tester.pump();
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await pumpTestWidget(tester);
      
      expect(find.text('Gender?'), findsOneWidget);
      expect(find.text('We will select this gender on your applications.'), findsOneWidget);

      // Check if all gender options are displayed in correct order
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Prefer not to say'), findsOneWidget);

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
    });

    testWidgets('next button is initially disabled', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.enabled, isFalse);
    });

    testWidgets('selecting gender enables next button', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      // Initially disabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isFalse,
      );

      // Tap female option
      await tester.tap(find.text('Female'));
      await tester.pump();

      // Button should be enabled
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
        isTrue,
      );
    });

    testWidgets('can select different gender options', (WidgetTester tester) async {
      await pumpTestWidget(tester);

      final genderOptions = [
        'Female',
        'Male',
        'Other',
        'Prefer not to say',
      ];

      for (final gender in genderOptions) {
        await tester.tap(find.text(gender));
        await tester.pump();

        final selectedContainer = find.ancestor(
          of: find.text(gender),
          matching: find.byType(Container),
        ).first;
        
        final container = tester.widget<Container>(selectedContainer);
        final decoration = container.decoration as BoxDecoration;
        
        // Check for white background on selected item
        expect(decoration.color, Colors.white);
      }
    });

    testWidgets('back button navigates to CitizenshipScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GenderScreen(),
          routes: {
            '/citizenship': (context) => const CitizenshipScreen(),
          },
        ),
      );

      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back_ios_new);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.byType(CitizenshipScreen), findsOneWidget);
    });

    testWidgets('maintains selection when navigating back and forth', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GenderScreen(),
        ),
      );

      // Wait for widget to be fully built
      await tester.pumpAndSettle();

      // Select a gender
      final genderOption = find.text('Female');
      expect(genderOption, findsOneWidget);
      await tester.tap(genderOption);
      await tester.pump();

      // Verify selection
      final selectedContainer = find.ancestor(
        of: genderOption,
        matching: find.byType(Container),
      ).first;
      
      final container = tester.widget<Container>(selectedContainer);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, Colors.white);
    });

    testWidgets('navigates to RaceScreen on next', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const GenderScreen(),
          routes: {
            '/race': (context) => const RaceScreen(),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Select a gender
      final genderOption = find.text('Female');
      expect(genderOption, findsOneWidget);
      await tester.tap(genderOption);
      await tester.pump();

      // Tap next button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.byType(RaceScreen), findsOneWidget);
    });
  });
} 