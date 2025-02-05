import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';

class WelcomeOnboardScreen extends StatelessWidget {
  const WelcomeOnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: size.height * 0.15),
                  // Logo text
                  Center(
                    child: Text(
                      'Grantly',
                      style: textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  // Welcome Text
                  Center(
                    child: Text(
                      "Let's find your next scholarship!",
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.06,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  // Commitment Text
                  Text(
                    "Our Commitment",
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  // Bullet points
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint(
                          context,
                          "We want to help you find scholarships that you will likely win",
                          size,
                        ),
                        SizedBox(height: size.height * 0.015),
                        _buildBulletPoint(
                          context,
                          "We think applying to scholarships should be easier",
                          size,
                        ),
                        SizedBox(height: size.height * 0.015),
                        _buildBulletPoint(
                          context,
                          "We're here to make that happen 👇",
                          size,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Fixed height for bottom spacing
                  // Get Started Button
                  SizedBox(
                    height: 56, // Fixed height for button
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const FirstNameScreen()),
                        );
                      },
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 16), // Fixed height for spacing
                  // Terms text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: size.width * 0.025,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By continuing, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Navigate to Terms
                              },
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Navigate to Privacy Policy
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Fixed height for bottom spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "•  ",
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.045,
            ),
          ),
        ),
      ],
    );
  }
} 