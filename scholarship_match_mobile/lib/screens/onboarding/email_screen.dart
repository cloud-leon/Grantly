import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final email = _controller.text.trim();
    setState(() {
      _canProceed = email.isNotEmpty && email.contains('@');
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your\nemail?',
      subtitle: 'We\'ll send you scholarship matches here.',
      inputField: OnboardingTextField(
        controller: _controller,
        focusNode: _focusNode,
        hintText: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
      ),
      previousScreen: const LastNameScreen(),
      onNext: () {
        NavigationUtils.onNext(context, const PhoneNumberScreen());
      },
      isNextEnabled: _canProceed,
    );
  }
}
