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

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _controller.removeListener(_validateInput);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _canProceed = _controller.text.trim().isNotEmpty;
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
      ),
      previousScreen: const FirstNameScreen(),
      onNext: () {
        NavigationUtils.onNext(context, const EmailScreen());
      },
      isNextEnabled: _canProceed,
    );
  }
}