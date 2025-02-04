import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: const Key('welcome_screen'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF7B4DFF), // Deep purple
              Color(0xFF4D9FFF), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08, // Responsive padding
                ),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.15), // Adjusted top spacing
                    // Logo text
                    Text(
                      'Grantly',
                      style: textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.12, // Responsive font size
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Slogan
                    Text(
                      'Find Your Perfect Scholarship Match',
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.06, // Responsive font size
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Terms and conditions text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: size.width * 0.025, // Responsive font size
                          ),
                          children: [
                            const TextSpan(
                              text: 'By tapping "Create account" or "Sign in", you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: Navigate to Terms page
                                },
                            ),
                            const TextSpan(
                              text: '. Learn how we process your data in our ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: Navigate to Privacy Policy page
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Cookies Policy',
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // TODO: Navigate to Cookies Policy page
                                },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    // Create Account button
                    SizedBox(
                      height: size.height * 0.065, // Fixed height for buttons
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text('Create Account'),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    // Sign In button
                    SizedBox(
                      height: size.height * 0.065, // Fixed height for buttons
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text('Sign In'),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    // Trouble Signing In button
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to trouble signing in page
                      },
                      child: Text(
                        'Trouble Signing In?',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 