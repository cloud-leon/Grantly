import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';

class WelcomeOnboardScreen extends StatelessWidget {
  const WelcomeOnboardScreen({super.key});

  Widget _buildBulletPoint(String text, Size size, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.06,
          ),
        ),
        SizedBox(width: size.width * 0.04),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Center(
                            child: Text(
                              'Grantly',
                              style: textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontSize: size.width * 0.2,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Center(
                            child: Text(
                              "Let your next scholarship find You!",
                              style: textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontSize: size.width * 0.06,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: size.height * 0.06),
                          // Commitment Text
                          Text(
                            "Our Commitment",
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          // Bullet points
                          _buildBulletPoint(
                            "We'll ask you a few questions to find the best scholarships for you This should take about 2 minutes",
                            size,
                            textTheme,
                          ),
                          SizedBox(height: size.height * 0.015),
                          _buildBulletPoint(
                            "We think applying to scholarships should be easier",
                            size,
                            textTheme,
                          ),
                          SizedBox(height: size.height * 0.015),
                          _buildBulletPoint(
                            "We're here to make that happen 👇",
                            size,
                            textTheme,
                          ),
                          Expanded(child: Container()), // This replaces the Spacer
                          Container(
                            width: double.infinity,
                            height: size.height * 0.065,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const FirstNameScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              child: const Text(
                                'GET STARTED',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          // Terms text at the bottom
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontSize: size.width * 0.025,
                                ),
                                children: [
                                  const TextSpan(text: 'By continuing, you agree to our '),
                                  TextSpan(
                                    text: 'Terms',
                                    style: const TextStyle(
                                      color: Color(0xFF0CEAD9),
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      // TODO: Navigate to Terms
                                    },
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Color(0xFF0CEAD9),
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      // TODO: Navigate to Privacy Policy
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 