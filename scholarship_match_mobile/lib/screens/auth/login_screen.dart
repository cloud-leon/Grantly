import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
// Temporarily comment out the Google sign in button until we re-add Firebase
// import 'package:scholarship_match_mobile/widgets/google_sign_in_button.dart';
import '../home/home_screen.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/phone_view_screen.dart';
import '../../services/profile_service.dart';
import '../../screens/onboarding/welcome_onboard_screen.dart';
import '../../providers/profile_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  String? _verificationId;
  final TextEditingController _phoneController = TextEditingController();

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    // Temporarily return a mock hash since we removed crypto package
    return input;
  }

  // Future<void> _handleAppleSignIn() async {
  //   try {
  //     setState(() => _isLoading = true);
  //     final credential = await _authService.signInWithApple();
  //     if (credential != null && mounted) {
  //       Navigator.pushReplacementNamed(context, '/home');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Sign in failed: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // Future<void> _handleGoogleSignIn() async {
  //   try {
  //     setState(() => _isLoading = true);
  //     final credential = await _authService.signInWithGoogle();
  //     if (credential != null && mounted) {
  //       Navigator.pushReplacementNamed(context, '/home');
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Sign in failed: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  void _showPhoneSignInDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PhoneViewScreen()),
    );
  }

  void _showOTPDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                if (value.length == 6) {
                  final credential = await _authService.verifyOTP(
                    verificationId: _verificationId!,
                    smsCode: value,
                  );
                  if (credential != null && mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handlePhoneAuth() async {
    if (_phoneController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        onCodeSent: (String verificationId) {
          Navigator.pushNamed(
            context,
            '/otp-verification',
            arguments: {
              'verificationId': verificationId,
              'phoneNumber': _phoneController.text,
            },
          );
        },
        onError: (String error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        },
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onLoginSuccess() {
    Navigator.pushReplacementNamed(context, '/onboarding/welcome');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
              Color(0xFF7B4DFF),
              Color(0xFF4D9FFF),
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
                  children: [
                    SizedBox(height: size.height * 0.15),
                    Text(
                      'Grantly',
                      style: textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.2,
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
                    // Terms and conditions text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: size.width * 0.025,
                          ),
                          children: [
                            const TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms',
                              style: const TextStyle(color: Color(0xFF0CEAD9)),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '. Learn how we process your data in our '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(color: Color(0xFF0CEAD9)),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Cookies Policy',
                              style: const TextStyle(color: Color(0xFF0CEAD9)),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(height: size.height * 0.03),
                    // SizedBox(
                    //   height: size.height * 0.065,
                    //   width: double.infinity,
                    //   child: ElevatedButton.icon(
                    //     icon: const Icon(Icons.apple),
                    //     label: _isLoading 
                    //       ? const SizedBox(
                    //           height: 20,
                    //           width: 20,
                    //           child: CircularProgressIndicator(
                    //             color: Colors.black,
                    //             strokeWidth: 2,
                    //           ),
                    //         )
                    //       : const Text('Continue with Apple'),
                    //     onPressed: _isLoading ? null : _handleAppleSignIn,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.white,
                    //       foregroundColor: Colors.black,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(26),
                    //       ),
                    //     ),
                    //   ),
                    // ), 
                    // SizedBox(height: size.height * 0.015),
                    // SizedBox(
                    //   height: size.height * 0.065,
                    //   width: double.infinity,
                    //   child: ElevatedButton.icon(
                    //     icon: const Icon(Icons.login),
                    //     label: const Text('Continue with Google'),
                    //     onPressed: _isLoading ? null : _handleGoogleSignIn,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.white,
                    //       foregroundColor: Colors.black,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(26),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: size.height * 0.015),
                    SizedBox(
                      height: size.height * 0.065,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone_android),
                        label: const Text(
                          'Continue with Phone',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _isLoading ? null : _showPhoneSignInDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
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
                          ),
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