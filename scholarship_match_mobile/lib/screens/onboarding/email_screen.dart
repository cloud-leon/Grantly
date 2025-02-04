import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';

class EmailScreen extends StatelessWidget {
  const EmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: "What's your\nemail address?",
      hintText: "Enter your email",
      subtitle: "We'll cfeate a private@eprivate email.com email address that fowareds to your personal email.",
      onNext: (value) {
        NavigationUtils.onNext(context, const PhoneNumberScreen());
      },
      onBack: () => NavigationUtils.onBack(context, const LastNameScreen()),
    );
  }
}
