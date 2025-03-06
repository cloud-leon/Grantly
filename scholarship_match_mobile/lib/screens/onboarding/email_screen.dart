import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import '../../providers/onboarding_provider.dart';
import 'dart:async';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canProceed = false;
  String? _errorText;
  Timer? _focusTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
    
    // Set initial value from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['email']?.isNotEmpty ?? false) {
      _emailController.text = onboardingData['email'];
      _validateInput();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusTimer?.cancel();
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (!mounted) return;
    
    final input = _emailController.text.trim();
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    setState(() {
      if (input.isEmpty) {
        _errorText = null;
        _canProceed = false;
      } else if (!emailRegex.hasMatch(input)) {
        _errorText = 'Please enter a valid email address';
        _canProceed = false;
      } else {
        _errorText = null;
        _canProceed = true;
      }
    });
  }

  void _saveAndContinue() {
    final email = _emailController.text.trim();
    if (!_canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('email', email);

    // Navigate to next screen with instant transition
    NavigationUtils.pushReplacementWithoutAnimation(context, const PhoneNumberScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your email?',
      subtitle: 'We\'ll use this to notify you about scholarships.',
      inputField: TextField(
        controller: _emailController,
        focusNode: _focusNode,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
        onChanged: (value) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              _validateInput();
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 20.0,
          ),
          errorText: _errorText,
          errorStyle: const TextStyle(fontSize: 16.0),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
      ),
      previousScreen: const DOBScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: _canProceed,
      nextButtonText: 'NEXT',
    );
  }
}
