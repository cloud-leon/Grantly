import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Models
import 'models/profile.dart';

// Screens
import 'screens/auth/login_screen.dart';
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
import 'screens/matches/matches_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/profile/profile_view_screen.dart';

// Providers
import 'providers/onboarding_provider.dart';
import 'providers/profile_provider.dart';

// Services
import 'services/profile_service.dart';
import 'services/auth_service.dart';

// Firebase config
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Grantly',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/onboarding':
              final uid = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (_) => WelcomeOnboardScreen(uid: uid ?? ''),
              );
            case '/otp-verification':
              final args = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder: (_) => OTPVerificationScreen(
                  verificationId: args['verificationId']!,
                  phoneNumber: args['phoneNumber']!,
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    print('Building AuthWrapper');  // Debug log
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('Auth state: ${snapshot.connectionState}');  // Debug log
        
        // Show loading only briefly
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          print('No user found, going to login');
          return const LoginScreen();
        }

        print('User authenticated: ${user.uid}');  // Debug log

        return FutureBuilder<Profile?>(
          future: ProfileService().getProfile(),
          builder: (context, profileSnapshot) {
            print('Profile fetch state: ${profileSnapshot.connectionState}');  // Debug log
            
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (profileSnapshot.hasError) {
              print('Profile error: ${profileSnapshot.error}');  // Debug log
              // Handle error gracefully - could show error screen or return to login
              return const LoginScreen();
            }

            final profile = profileSnapshot.data;
            print('Profile loaded: ${profile?.isComplete}');  // Debug log

            if (profile == null || !profile.isComplete) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed(
                  '/onboarding',
                  arguments: user.uid,
                );
              });
              return const LoadingScreen();
            }

            // Store profile in provider before building HomeScreen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.read<ProfileProvider>().setProfile(profile);
            });
            
            return const HomeScreen();
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    print('AuthWrapper initialized');  // Debug log
  }
}
