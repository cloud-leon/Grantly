import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/welcome_onboard_screen.dart';
import 'screens/onboarding/first_name_screen.dart';
import 'screens/onboarding/last_name_screen.dart';
import 'screens/onboarding/email_screen.dart';
import 'screens/onboarding/phone_number_screen.dart';
import 'screens/onboarding/dob_screen.dart';
import 'screens/onboarding/gender_screen.dart';
import 'screens/onboarding/citizenship_screen.dart';
import 'screens/onboarding/race_screen.dart';
import 'screens/onboarding/disabilities_screen.dart';
import 'screens/onboarding/first_gen_screen.dart';
import 'screens/onboarding/financial_aid_screen.dart';
import 'screens/onboarding/military_screen.dart';
import 'screens/onboarding/grade_level_screen.dart';
import 'screens/onboarding/location_screen.dart';
import 'screens/onboarding/hear_about_us_screen.dart';
import 'screens/onboarding/referral_code_screen.dart';
import 'dart:async';  // Add this import for Timer

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _initTimer;

  @override
  void dispose() {
    _initTimer?.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grantly',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF7B4DFF), // Deep purple base
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF7B4DFF), // Deep purple
          secondary: Color(0xFF4D9FFF), // Light blue
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF7B4DFF),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/welcome-onboard': (context) => const WelcomeOnboardScreen(),
        '/hear-about-us': (context) => const HearAboutUsScreen(),
        '/first-name': (context) => const FirstNameScreen(),
        '/last-name': (context) => const LastNameScreen(),
        '/email': (context) => const EmailScreen(),
        '/phone': (context) => const PhoneNumberScreen(),
        '/gender': (context) => const GenderScreen(),
        '/citizenship': (context) => const CitizenshipScreen(),
        '/dob': (context) => const DOBScreen(),
        '/race': (context) => const RaceScreen(),
        '/disabilities': (context) => const DisabilitiesScreen(),
        '/first-gen': (context) => const FirstGenScreen(),
        '/financial-aid': (context) => const FinancialAidScreen(),
        '/military': (context) => const MilitaryScreen(),
        '/grade-level': (context) => const GradeLevelScreen(),
        '/location': (context) => const LocationScreen(),
        '/referral-code': (context) => const ReferralCodeScreen(),
      },
    );
  }
}
