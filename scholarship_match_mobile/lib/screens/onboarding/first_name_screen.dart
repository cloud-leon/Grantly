import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/welcome_onboard_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'dart:async';

class FirstNameScreen extends StatefulWidget {
  const FirstNameScreen({super.key});

  @override
  State<FirstNameScreen> createState() => _FirstNameScreenState();
}

class _FirstNameScreenState extends State<FirstNameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canProceed = false;
  String? _errorText;
  Timer? _focusTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
    // Request focus after build
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  void _validateInput() {
    final input = _controller.text.trim();
    final RegExp nameRegex = RegExp(r"^[a-zA-Z\s'.-]+$");
    
    setState(() {
      if (input.isEmpty) {
        _errorText = null;
        _canProceed = false;
      } else if (!nameRegex.hasMatch(input)) {
        _errorText = 'Please enter a valid name';
        _canProceed = false;
      } else {
        _errorText = null;
        _canProceed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your first name?',
      subtitle: 'We\'ll use this to find scholarships.',
      inputField: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Enter your first name',
          errorText: _errorText,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      previousScreen: const WelcomeOnboardScreen(),
      onNext: () {
        if (_canProceed) {
          NavigationUtils.onNext(context, const LastNameScreen());
        }
      },
      isNextEnabled: _canProceed,
    );
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _controller.removeListener(_validateInput);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
} 