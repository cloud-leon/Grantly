import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';

class DOBScreen extends StatelessWidget {
  const DOBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What is your\ndate of birth?',
      hintText: 'MM/DD/YYYY',
      subtitle: 'We will use this to find age-specific scholarships.',
      keyboardType: TextInputType.datetime,
      onNext: (value) {
        NavigationUtils.onNext(context, const CitizenshipScreen());
      },
      onBack: () => NavigationUtils.onBack(context, const PhoneNumberScreen()),
    );
  }
} 