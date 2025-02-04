import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/welcome_onboard_screen.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';

class FirstNameScreen extends StatelessWidget {
  const FirstNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What is your\nfirst name?',
      hintText: 'Enter your first name',
      subtitle: 'Please enter your first name as it appears on your\ngovernement issued ID.',
      onNext: (value) {
        NavigationUtils.onNext(context, const LastNameScreen());
      },
      onBack: () => NavigationUtils.onBack(context, const WelcomeOnboardScreen()),
    );
  }
} 