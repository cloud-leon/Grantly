import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_name_screen.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';

class LastNameScreen extends StatelessWidget {
  const LastNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: "What is your\nlast name?",
      hintText: "Enter your last name",
      subtitle: "Please enter your last name as it appears on your\ngovernement issued ID.",
      onNext: (value) {
        NavigationUtils.onNext(context, const EmailScreen());
      },
      onBack: () => NavigationUtils.onBack(context, const FirstNameScreen()),
    );
  }
}