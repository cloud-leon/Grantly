import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.02,
                        left: size.width * 0.02,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: size.width * 0.03,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.08),
                          Text(
                            'Grantly',
                            style: textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Text(
                            'Find Your Perfect Scholarship Match',
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.06,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          // Add Terms and conditions text
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
                          SizedBox(
                            height: size.height * 0.065,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.apple),
                              label: const Text('Sign in with Apple'),
                              onPressed: () {
                                // TODO: Implement Apple sign in
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          SizedBox(
                            height: size.height * 0.065,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.g_mobiledata), // Google icon
                              label: const Text('Sign in with Google'),
                              onPressed: () {
                                // TODO: Implement Google sign in
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          SizedBox(
                            height: size.height * 0.065,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.phone_android),
                              label: const Text('Sign in with Phone Number'),
                              onPressed: () {
                                // TODO: Implement phone sign in
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                // TODO: Navigate to trouble signing in page
                              },
                              child: Text(
                                'Trouble Signing In?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.035,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.05),
                        ],
                      ),
                    ),
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