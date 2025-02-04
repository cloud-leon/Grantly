import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';

class GenderScreen extends StatelessWidget {
  const GenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'Gender?',
      subtitle: 'We will select this gender on your applications.',
      options: const [
        'Male',
        'Female',
        'Other',
        'Prefer not to say',
      ],
      previousScreen: const CitizenshipScreen(),
      onNext: (selectedOption) {
        // TODO: Navigate to next screen
      },
    );
  }
} 