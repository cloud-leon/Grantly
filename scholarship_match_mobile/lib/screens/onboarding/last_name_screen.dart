import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'dart:async';

class LastNameScreen extends StatefulWidget {
  const LastNameScreen({super.key});

  @override
  State<LastNameScreen> createState() => _LastNameScreenState();
}

class _LastNameScreenState extends State<LastNameScreen> {
  final TextEditingController _controller = TextEditingController();
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
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (!mounted) return;
    
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
      title: 'What\'s your last name?',
      subtitle: 'We\'ll use this on your applications.',
      inputField: OnboardingTextField(
        controller: _controller,
        focusNode: _focusNode,
        hintText: 'Enter your last name',
        onChanged: (value) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              _validateInput();
            }
          });
        },
      ),
      previousScreen: const FirstNameScreen(),
      onNext: () {
        NavigationUtils.onNext(context, const EmailScreen());
      },
      isNextEnabled: _canProceed,
    );
  }
}