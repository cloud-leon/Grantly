import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import '../../providers/onboarding_provider.dart';
import 'dart:async';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';

class LastNameScreen extends StatefulWidget {
  const LastNameScreen({super.key});

  @override
  State<LastNameScreen> createState() => _LastNameScreenState();
}

class _LastNameScreenState extends State<LastNameScreen> {
  final TextEditingController _lastNameController = TextEditingController();
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
    if (onboardingData['last_name']?.isNotEmpty ?? false) {
      _lastNameController.text = onboardingData['last_name'];
      _validateInput();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusTimer?.cancel();
    _lastNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (!mounted) return;
    
    final input = _lastNameController.text.trim();
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

  void _saveAndContinue() {
    final lastName = _lastNameController.text.trim();
    if (!_canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid last name')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('last_name', lastName);

    // Navigate to next screen with instant transition
    NavigationUtils.pushReplacementWithoutAnimation(context, const DOBScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your last name?',
      subtitle: 'We\'ll use this to find scholarships.',
      inputField: TextField(
        controller: _lastNameController,
        focusNode: _focusNode,
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
          hintText: 'Enter your last name',
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
      previousScreen: const FirstNameScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: _canProceed,
      nextButtonText: 'NEXT',
    );
  }
}