import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import 'dart:async';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canProceed = false;
  String? _errorText;
  Timer? _focusTimer;
  Timer? _debounceTimer;

  // Regular expression for email validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

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
    
    final email = _controller.text.trim();
    setState(() {
      if (email.isEmpty) {
        _errorText = null;
        _canProceed = false;
      } else if (!_emailRegex.hasMatch(email)) {
        _errorText = 'Please enter a valid email address';
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
      title: 'What\'s your email?',
      subtitle: 'We\'ll send you scholarship matches here.',
      inputField: OnboardingTextField(
        controller: _controller,
        focusNode: _focusNode,
        hintText: 'Enter your email',
        errorText: _errorText,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onChanged: (value) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              _validateInput();
            }
          });
        },
      ),
      previousScreen: const LastNameScreen(),
      onNext: () {
        NavigationUtils.onNext(context, const PhoneNumberScreen());
      },
      isNextEnabled: _canProceed,
    );
  }
}
